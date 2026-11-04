import contextlib
import io
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import dev


class DevTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        previous = Path.cwd()
        os.chdir(self.temporary.name)
        self.addCleanup(os.chdir, previous)
        Path("lib").mkdir()
        Path("web").mkdir()
        Path("pubspec.yaml").write_text("name: example\n")
        Path("lib/main.dart").write_text("void main() {}\n")

    def test_snapshot_detects_content_even_with_unchanged_mtime(self):
        before = dev.snapshot()
        path = Path("lib/main.dart")
        stat = path.stat()
        path.write_text("void main() { }\n")
        os.utime(path, ns=(stat.st_atime_ns, stat.st_mtime_ns))
        self.assertNotEqual(before, dev.snapshot())

    def test_snapshot_detects_creation_deletion_web_assets_and_dependencies(self):
        Path("assets").mkdir()
        for name in ("lib/new.dart", "web/index.html", "assets/test.txt", "pubspec.lock"):
            with self.subTest(name=name):
                before = dev.snapshot()
                path = Path(name)
                path.write_text("new")
                self.assertNotEqual(before, dev.snapshot())
                path.unlink()
                self.assertEqual(before, dev.snapshot())

    def test_revision_does_not_trigger_compilation(self):
        before = dev.snapshot()
        dev.publish_revision()
        first = json.loads(dev.REVISION.read_text())["revision"]
        dev.publish_revision()
        self.assertNotEqual(first, json.loads(dev.REVISION.read_text())["revision"])
        self.assertEqual(before, dev.snapshot())

    def test_machine_protocol_serializes_edits_and_recovers_after_failure(self):
        class FakeFlutter:
            returncode = None

            def __init__(self):
                self.stdout = io.StringIO(
                    '[{"event":"app.started","params":{"appId":"test"}}]\n')
                self.stdin = io.StringIO()

            def poll(self):
                return self.returncode

            def terminate(self):
                self.returncode = 0

            def wait(self, timeout=None):
                return self.returncode

        process = FakeFlutter()
        output = dev.queue.Queue()
        ticks = 0

        def commands():
            return [json.loads(line)[0] for line in process.stdin.getvalue().splitlines()]

        def advance(_):
            nonlocal ticks
            ticks += 1
            if ticks == 1:
                Path("lib/main.dart").write_text("first edit")
            elif ticks == 3:
                self.assertEqual(len(commands()), 1)
                Path("lib/main.dart").write_text("edit during compilation")
            elif ticks == 5:
                self.assertEqual(len(commands()), 1)
                output.put('[{"id":1,"result":{"code":0}}]')
            elif ticks == 6:
                self.assertEqual(len(commands()), 2)
                output.put('[{"id":2,"result":{"code":1,"message":"compile error"}}]')
            elif ticks == 7:
                Path("lib/main.dart").write_text("fixed")
            elif ticks == 9:
                self.assertEqual(len(commands()), 3)
                output.put('[{"id":3,"result":{"code":0}}]')
            elif ticks == 10:
                self.assertEqual(len(commands()), 3)
                for command in commands():
                    self.assertEqual(command["method"], "app.restart")
                    self.assertTrue(command["params"]["fullRestart"])
                raise KeyboardInterrupt

        with (patch.object(dev.subprocess, "run"),
              patch.object(dev.subprocess, "Popen", return_value=process),
              patch.object(dev.queue, "Queue", return_value=output),
              patch.object(dev.time, "sleep", side_effect=advance),
              patch.object(dev.time, "monotonic", side_effect=lambda: ticks),
              patch.object(dev, "publish_revision") as publish,
              contextlib.redirect_stdout(io.StringIO())):
            with self.assertRaises(KeyboardInterrupt):
                dev.run_flutter()
            # Initial build and successful requests only; never the failed build.
            self.assertEqual(publish.call_count, 3)


if __name__ == "__main__":
    unittest.main()
