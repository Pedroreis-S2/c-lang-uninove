const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const vm = require('node:vm');

const source = fs.readFileSync(
  path.join(__dirname, '../web/flutter_bootstrap.js'), 'utf8',
).replace('{{flutter_js}}', '').replace('{{flutter_build_config}}', '');

function browser(compileTarget, responses) {
  const state = { requests: 0, reloads: 0, warnings: 0, loads: 0, timers: [] };
  vm.runInNewContext(source, {
    _flutter: {
      buildConfig: { builds: [{ compileTarget }] },
      loader: { load: () => state.loads++ },
    },
    document: { baseURI: 'https://codespace.example/' },
    window: { location: { reload: () => state.reloads++ } },
    console: { warn: () => state.warnings++ },
    URL,
    setTimeout: (callback) => state.timers.push(callback),
    fetch: async (url, options) => {
      state.requests++;
      assert.equal(url.href, 'https://codespace.example/.dev-reload.json');
      assert.equal(options.cache, 'no-store');
      const revision = responses.shift();
      return { ok: revision !== null, status: 503, json: async () => ({ revision }) };
    },
  });
  return state;
}

const settle = () => new Promise((resolve) => setImmediate(resolve));

test('producao carrega Flutter sem polling', async () => {
  for (const target of ['dart2js', 'dart2wasm']) {
    const state = browser(target, []);
    await settle();
    assert.equal(state.loads, 1);
    assert.equal(state.requests, 0);
    assert.equal(state.timers.length, 0);
  }
});

test('debug recarrega somente quando a revisao muda', async () => {
  const state = browser('dartdevc', ['one', 'one', 'two']);
  await settle();
  assert.equal(state.reloads, 0);
  await state.timers.shift()();
  assert.equal(state.reloads, 0);
  await state.timers.shift()();
  assert.equal(state.reloads, 1);
  assert.equal(state.timers.length, 0);
});

test('indisponibilidade e resposta invalida nao recarregam; recuperacao continua', async () => {
  const state = browser('dartdevc', ['one', null, undefined, 'two']);
  await settle();
  await state.timers.shift()();
  await state.timers.shift()();
  assert.equal(state.reloads, 0);
  assert.equal(state.warnings, 1);
  await state.timers.shift()();
  assert.equal(state.reloads, 1);
});
