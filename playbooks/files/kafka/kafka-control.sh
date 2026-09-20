#!/usr/bin/env bash
set -euo pipefail

# Override these via environment variables if needed.
# Defaults target the stock Kafka directory layout.
KAFKA_HOME="${KAFKA_HOME:-$HOME/app/kafka}"
KAFKA_CONFIG="${KAFKA_CONFIG:-$KAFKA_HOME/config/server.properties}"
KAFKA_STORAGE_BIN="${KAFKA_STORAGE_BIN:-$KAFKA_HOME/bin/kafka-storage.sh}"
KAFKA_START_BIN="${KAFKA_START_BIN:-$KAFKA_HOME/bin/kafka-server-start.sh}"
KAFKA_STOP_BIN="${KAFKA_STOP_BIN:-$KAFKA_HOME/bin/kafka-server-stop.sh}"

log() {
  printf '[kafka-control] %s\n' "$*"
}

config_value() {
  local key="$1"
  awk -F= -v k="$key" '
    /^[[:space:]]*#/ { next }
    $1 ~ "^[[:space:]]*" k "[[:space:]]*$" {
      v=$2
      sub(/^[[:space:]]+/, "", v)
      sub(/[[:space:]]+$/, "", v)
      print v
      exit
    }
  ' "$KAFKA_CONFIG"
}

require_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    log "Missing required file: $path"
    exit 1
  fi
}

init_kraft() {
  require_file "$KAFKA_CONFIG"
  require_file "$KAFKA_STORAGE_BIN"

  local metadata_dir
  metadata_dir="$(config_value metadata.log.dir)"
  if [ -z "$metadata_dir" ]; then
    metadata_dir="$(config_value log.dirs)"
    metadata_dir="${metadata_dir%%,*}"
  fi

  local meta_props
  meta_props="$metadata_dir/meta.properties"
  if [ -f "$meta_props" ]; then
    log "KRaft storage already formatted at $metadata_dir; skipping format"
    return 0
  fi

  local cluster_id
  cluster_id="$($KAFKA_STORAGE_BIN random-uuid)"

  log "Formatting storage for KRaft (safe to re-run)"
  "$KAFKA_STORAGE_BIN" format --standalone -t "$cluster_id" -c "$KAFKA_CONFIG" --ignore-formatted
}

is_running() {
  pgrep -f "kafka.Kafka $KAFKA_CONFIG" >/dev/null 2>&1
}

start_kafka() {
  init_kraft

  if is_running; then
    log "Kafka is already running"
    return 0
  fi

  log "Starting Kafka in daemon mode"
  "$KAFKA_START_BIN" "$KAFKA_CONFIG"
  log "Kafka start command issued"
}

stop_kafka() {
  if ! is_running; then
    log "Kafka is not running"
    return 0
  fi

  log "Stopping Kafka"
  "$KAFKA_STOP_BIN"

  for _ in $(seq 1 30); do
    if ! is_running; then
      log "Kafka stopped"
      return 0
    fi
    sleep 1
  done

  log "Kafka did not stop within timeout"
  exit 1
}

status_kafka() {
  if is_running; then
    log "Kafka is running"
  else
    log "Kafka is stopped"
    return 1
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") {start|stop|restart|status|init-kraft}

Environment overrides:
  KAFKA_HOME
  KAFKA_CONFIG
  KAFKA_STORAGE_BIN
  KAFKA_START_BIN
  KAFKA_STOP_BIN
EOF
}

cmd="${1:-}"
case "$cmd" in
  start)
    start_kafka
    ;;
  stop)
    stop_kafka
    ;;
  restart)
    stop_kafka
    start_kafka
    ;;
  status)
    status_kafka
    ;;
  init-kraft)
    init_kraft
    ;;
  *)
    usage
    exit 2
    ;;
esac
