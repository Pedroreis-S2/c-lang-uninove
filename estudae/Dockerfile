# syntax=docker/dockerfile:1

# Versao do Flutter definida em UM lugar so. Para atualizar, troque aqui
# (e no Dockerfile.dev) e rode `docker compose build`.
ARG FLUTTER_VERSION=3.24.5

# ============================================================================
# Estagio 1 - build: compila o app Flutter para web
# ============================================================================
FROM ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION} AS build

WORKDIR /app

# 1) Dependencias primeiro: esta camada so e refeita quando o pubspec muda.
#    O cache mount guarda os pacotes baixados entre builds.
COPY pubspec.yaml pubspec.lock ./
RUN --mount=type=cache,target=/root/.pub-cache \
    flutter pub get

# 2) Codigo e build.
#    --no-web-resources-cdn: empacota o CanvasKit no proprio build, em vez de
#    baixar do www.gstatic.com na hora de abrir a pagina (evita tela em branco
#    quando a rede esta lenta ou bloqueada).
#    --pwa-strategy=none: sem service worker, entao nao ha cache velho no navegador.
COPY . .
RUN --mount=type=cache,target=/root/.pub-cache \
    flutter build web --release --no-web-resources-cdn --pwa-strategy=none

# ============================================================================
# Estagio 2 - runtime: nginx servindo so os arquivos estaticos
# ============================================================================
FROM nginx:1.27-alpine AS runtime

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/app.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
