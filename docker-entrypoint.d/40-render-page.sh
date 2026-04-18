#!/bin/sh
set -eu

template="/usr/share/nginx/html/index.template.html"
output="/usr/share/nginx/html/index.html"

if [ -f "${template}" ]; then
  envsubst '${APP_MODE} ${APP_MESSAGE} ${APP_PORT}' < "${template}" > "${output}"
else
  echo "40-render-page.sh: index.template.html not found, skipping template rendering" >&2
fi
