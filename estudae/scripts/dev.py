#!/usr/bin/env python3
"""Supervisiona o Flutter web sem terminal ou extensao de depuracao."""

import hashlib
import json
import queue
import signal
import subprocess
import threading
import time
import uuid
from pathlib import Path


REVISION = Path("web/.dev-reload.json")


def snapshot():
    files = [Path("pubspec.yaml"), Path("pubspec.lock")]
    for folder in ("lib", "web", "assets"):
        files.extend(Path(folder).rglob("*"))
    result = {}
    for path in sorted(files):
        if not path.is_file() or path.name.startswith(".dev-reload.json"):
            continue
        try:
            result[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
        except FileNotFoundError:
            # Salvamentos atomicos podem remover o arquivo entre stat e read.
            continue
    return result


def publish_revision():
    temporary = REVISION.with_suffix(".json.tmp")
    temporary.write_text(json.dumps({"revision": uuid.uuid4().hex}))
    temporary.replace(REVISION)


def read_output(process, output):
    for line in process.stdout:
        output.put(line.rstrip())


def stop(process):
    if process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            print("[dev] Flutter nao encerrou em 10s; encerrando o processo.", flush=True)
            process.kill()
            process.wait()
    process.stdin.close()
    process.stdout.close()


def run_flutter():
    subprocess.run(["flutter", "pub", "get"], check=True)
    requested = snapshot()
    observed = requested
    changed_at = time.monotonic()
    process = subprocess.Popen(
        ["flutter", "run", "--machine", "-d", "web-server",
         "--web-hostname", "0.0.0.0", "--web-port", "5000"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, text=True, bufsize=1,
    )
    output = queue.Queue()
    reader = threading.Thread(target=read_output, args=(process, output), daemon=True)
    reader.start()
    app_id = None
    pending = None
    request_id = 0
    try:
        while True:
            while not output.empty():
                line = output.get_nowait()
                try:
                    messages = json.loads(line)
                except json.JSONDecodeError:
                    print(line, flush=True)
                    continue
                if not isinstance(messages, list):
                    print(line, flush=True)
                    continue
                for message in messages:
                    print(json.dumps(message), flush=True)
                    if message.get("event") == "app.started":
                        app_id = message["params"]["appId"]
                        publish_revision()
                        print("[dev] Pronto; observando lib/, web/, assets/ e pubspec.", flush=True)
                    if pending is not None and message.get("id") == pending:
                        pending = None
                        if "error" in message or message.get("result", {}).get("code") != 0:
                            print("[dev] Compilacao falhou; corrija e salve novamente.", flush=True)
                        else:
                            publish_revision()
                            print("[dev] Compilacao concluida; atualizando navegador.", flush=True)
            if process.poll() is not None:
                raise RuntimeError(f"Flutter encerrou inesperadamente: {process.returncode}")

            current = snapshot()
            if current != observed:
                observed = current
                changed_at = time.monotonic()
            if (app_id is not None and pending is None and observed != requested
                    and time.monotonic() - changed_at >= 0.5):
                if any(observed.get(name) != requested.get(name)
                       for name in ("pubspec.yaml", "pubspec.lock")):
                    print("[dev] pubspec alterado; resolvendo dependencias e reiniciando.", flush=True)
                    return
                requested = observed
                request_id += 1
                pending = request_id
                command = [{"id": pending, "method": "app.restart", "params": {
                    "appId": app_id, "fullRestart": True, "pause": False,
                }}]
                print("[dev] Mudanca detectada -> hot restart", flush=True)
                process.stdin.write(json.dumps(command) + "\n")
                process.stdin.flush()
            time.sleep(0.25)
    finally:
        stop(process)
        reader.join(timeout=1)


def main():
    def interrupt(signum, frame):
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, interrupt)
    try:
        while True:
            run_flutter()
    except KeyboardInterrupt:
        print("[dev] Encerrando.", flush=True)
    finally:
        REVISION.unlink(missing_ok=True)
        REVISION.with_suffix(".json.tmp").unlink(missing_ok=True)


if __name__ == "__main__":
    main()
