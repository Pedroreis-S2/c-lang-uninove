#!/bin/sh
# Sobe o Flutter web com recarga automatica.
#
# No Windows o bind mount do Docker sincroniza o conteudo dos arquivos, mas nao
# envia os eventos de alteracao (inotify) para dentro do container, entao o
# watcher do proprio Flutter nunca dispara. Aqui um laco verifica a pasta lib/
# por mudancas (por tempo de modificacao) e manda o Flutter fazer hot restart.
set -e
cd "$(dirname "$0")/.."

flutter pub get

PIPE=/tmp/flutter_stdin
rm -f "$PIPE"
mkfifo "$PIPE"

# Roda o Flutter lendo os comandos do pipe; fd 3 mantem o pipe aberto p/ escrita.
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000 < "$PIPE" &
FLUTTER_PID=$!
exec 3> "$PIPE"

assinatura() {
  find lib pubspec.yaml -type f -printf '%T@ %p\n' 2>/dev/null | sort | md5sum
}

ultima="$(assinatura)"
while kill -0 "$FLUTTER_PID" 2>/dev/null; do
  sleep 1
  atual="$(assinatura)"
  if [ "$atual" != "$ultima" ]; then
    ultima="$atual"
    echo "[dev] mudanca detectada -> hot restart"
    printf 'R\n' >&3
  fi
done
