FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="codyssey-workstation-web" \
      org.opencontainers.image.description="Custom NGINX image for the AI/SW development workstation mission"

ENV APP_MODE=standalone \
    APP_MESSAGE="AI/SW development workstation is ready." \
    APP_PORT=80

COPY app/ /usr/share/nginx/html/
COPY docker-entrypoint.d/40-render-page.sh /docker-entrypoint.d/40-render-page.sh

RUN chmod +x /docker-entrypoint.d/40-render-page.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${APP_PORT}/ >/dev/null || exit 1
