#!/usr/bin/env bash
# wait-for-postgres.sh
set -e

WAITFORPG_HOST=localhost
WAITFORPG_PORT=5432
WAITFORPG_DB=postgres
WAITFORPG_USER=postgres
WAITFORPG_PASSWORD=postgres
WAITFORPG_TIMEOUT=10

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        --host=*)
        WAITFORPG_HOST="${1#*=}"
        shift 1
        ;;
        --port=*)
        WAITFORPG_PORT="${1#*=}"
        shift 1
        ;;
        --db=*)
        WAITFORPG_DB="${1#*=}"
        shift 1
        ;;
        --user=*)
        WAITFORPG_USER="${1#*=}"
        shift 1
        ;;
        --pass=*)
        WAITFORPG_PASSWORD="${1#*=}"
        shift 1
        ;;
        --timeout=*)
        WAITFORPG_TIMEOUT="${1#*=}"
        shift 1
        ;;
        --)
        shift
        WAITFORPG_CMD=("$@")
        break
        ;;
        *)
        echo "Unknown argument: $1"
        ;;
    esac
done

until PGPASSWORD=$WAITFORPG_PASSWORD psql -h "$WAITFORPG_HOST" -p $WAITFORPG_PORT -U "$WAITFORPG_USER" -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping $WAITFORPG_TIMEOUT"
  sleep $WAITFORPG_TIMEOUT
done

>&2 echo "Postgres is up - executing command: ${WAITFORPG_CMD[@]}"
exec "${WAITFORPG_CMD[@]}"
