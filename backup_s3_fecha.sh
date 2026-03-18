#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ------------ Configuración ------------
LOCAL_DIR="${1:-/ruta/a/tu/carpeta}"
S3_BUCKET="${2:-mi-bucket-backup}"  # Sin s3://
AWS_PROFILE="${AWS_PROFILE:-default}"
LOG_DIR="${HOME}/backup_logs"

# ISO timestamp
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
DESTINO="s3://${S3_BUCKET}/backup_${TIMESTAMP}"

# Excluir patrones opcionales
EXCLUDES=(
  "--exclude" ".git/*"
  "--exclude" "*.tmp"
  "--exclude" "node_modules/*"
)

mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/backup_${TIMESTAMP}.log"

echo "=== Backup iniciado: $(date) ===" | tee -a "${LOG_FILE}"
echo "Local: ${LOCAL_DIR}" | tee -a "${LOG_FILE}"
echo "S3 destino: ${DESTINO}" | tee -a "${LOG_FILE}"
echo "Perfil AWS: ${AWS_PROFILE}" | tee -a "${LOG_FILE}"

# Chequeos básicos
if [[ ! -d "${LOCAL_DIR}" ]]; then
  echo "ERROR: la carpeta local no existe: ${LOCAL_DIR}" | tee -a "${LOG_FILE}"
  exit 2
fi

# Sincroniza (sube) todos los archivos al prefijo con fecha
aws s3 sync \
  "${LOCAL_DIR}" \
  "${DESTINO}" \
  --profile "${AWS_PROFILE}" \
  --exact-timestamps \
  --storage-class STANDARD_IA \
  "${EXCLUDES[@]}" \
  2>&1 | tee -a "${LOG_FILE}"

RC=${PIPESTATUS[0]}
if [[ ${RC} -ne 0 ]]; then
  echo "ERROR en sincronización (rc=${RC})" | tee -a "${LOG_FILE}"
  exit ${RC}
fi

echo "Backup completado: $(date)" | tee -a "${LOG_FILE}"
echo "Directorio en S3 creado: ${DESTINO}" | tee -a "${LOG_FILE}"
exit 0
