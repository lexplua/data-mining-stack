#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [--no-browser] [-w N]

Starts MinIO, Spark with Delta Lake support and Jupyter notebook to play around

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
--no-browser    Do not open browser with Jupyter lab
-w N| --spark-workers N Set Spark workers count to N

Example: $(basename "${BASH_SOURCE[0]}") -w 5 --no-browser  : Run stack with 5 Spark workers and do not open browser with Jupyter notebook
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help)
        usage
        ;;
    -v | --verbose)
        set -x
        ;;
    --no-browser)
        NO_BROWSER=1
        ;;
    --no-color)
        NO_COLOR=1
        ;;
    -w | --spark-workers)
        SPARK_WORKERS="${2-}"
        if ! [[ "${SPARK_WORKERS}" =~ ^[0-9]+$ ]]
        then
            die "Worker count should be integer"
        fi
        if ! [[ "${SPARK_WORKERS}" -gt 0 ]] 2>/dev/null
        then
            die "Worker count should be positive"
        fi
        shift
      ;;
    -?*)
        die "Unknown option: $1"
        ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  return 0
}

SPARK_WORKERS=1
parse_params "$@"
echo "SPARK WORKERS SET TO ${SPARK_WORKERS}"

setup_colors

# Start containers

docker compose up --build -d --scale spark-worker="${SPARK_WORKERS}"
until [ $(docker inspect -f {{.State.Health.Status}}  jupyter-notebook) == "healthy" ]; do
    sleep 0.1;
done;

LAB_TOKEN=$(docker compose exec jupyter-notebook jupyter server list --jsonlist|grep token|awk -F'"' '{print $4}')
LAB_PORT=$(docker compose exec jupyter-notebook jupyter server list --jsonlist|grep port|awk -F' ' '{print $2}'|sed 's/,/\//g')
JUPYTER_URL="http://localhost:${LAB_PORT}?token=${LAB_TOKEN}"
msg "\n\n"
msg "${GREEN}Jupyter notebook URL:\t${JUPYTER_URL}"

source .env
msg "${GREEN}MinIO UI URL:\t\t${MINIO_ENDPOINT_URL}"
msg "${CYAN}MinIO credentials:\n \tusername: ${AWS_ACCESS_KEY_ID}\n \tpassword: ${AWS_SECRET_ACCESS_KEY}"

SPARK_MASTER_URL="http://localhost:8080"
msg "${GREEN}Spark Master URL:\t${SPARK_MASTER_URL}"

MLFLOW_URL="http://localhost:${MLFLOW_PORT}"
msg "${GREEN}MLFlow URL:\t\t${MLFLOW_URL}${NOFORMAT}"

if [[ -z "${NO_BROWSER-}" ]]; then
  open "${JUPYTER_URL}"
fi
