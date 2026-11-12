{{flutter_js}}
{{flutter_build_config}}

// O web-server recompila, mas nao recarrega navegadores sem depurador.
// Builds de producao nao iniciam este polling.
if (_flutter.buildConfig.builds.some((build) => build.compileTarget === 'dartdevc')) {
  let revision;
  let unavailable = false;
  async function checkRevision() {
    try {
      const response = await fetch(new URL('.dev-reload.json', document.baseURI), {
        cache: 'no-store',
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const state = await response.json();
      if (typeof state.revision !== 'string') throw new Error('Invalid dev revision');
      if (revision !== undefined && revision !== state.revision) {
        window.location.reload();
        return;
      }
      revision = state.revision;
      unavailable = false;
    } catch (error) {
      if (!unavailable) console.warn('[dev] Recarga indisponivel; tentando novamente.', error);
      unavailable = true;
    }
    setTimeout(checkRevision, 1000);
  }
  checkRevision();
}

_flutter.loader.load();
