#!/usr/bin/env bash
set -euo pipefail
while true; do
  echo "[entrypoint] servicio activo en $(hostname) -> $(date -Is)"
  sleep 30
done
