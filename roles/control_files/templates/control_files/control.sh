#!/bin/bash
set -e

DETACH=--detach
TAG=latest

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATE_TAG=$(date +%Y%m%d%H%M%S)

BUILD_PATH="{{ build_path }}"
DOCKER_DATA_PATH="{{ docker_data_path }}"
BACKUP_PATH="{{ backup_path }}"
REGISTRY="{{ registry_url }}"

PROJ_CONTROL_FILE="{{ build_path }}/{{project}}"
PROJ_COMPOSE_FILE="{{ build_path }}/{{project}}.yml"

IMAGES_NAME_SUFFIX="{{registry_url}}{{project}}-"
DELIM_TAG="!!"
DELIM_REGISTRY="__"

backup() {
    local original_tag=$1

    local backup_tag=bkp_${DATE_TAG}
    local backup_to_dir=${BACKUP_PATH}/${DATE_TAG}
    local backup_docker_images_dir=${backup_to_dir}/docker_images

    local image_sources_backup_file=image_sources.tar.gz
    local pki_backup_file=pki.tar.gz
    local docker_data_backup_file=docker_data.tar.gz

    mkdir -p $backup_docker_images_dir

    local containers=$(docker ps -a \
    | grep "${IMAGES_NAME_SUFFIX}" \
    | awk '{print $1";"$2}')

    echo Saving docker containers ...

    for i in $containers; do
      local cont_and_name=(${i//;/ })
      local cont=${cont_and_name[0]}
      local name=${cont_and_name[1]}

      echo "    ${name}"
      docker commit ${cont} ${name}__${backup_tag}
    done

    echo Stopping project ...

    ./$0 down

    echo Saving docker images ...

    local images=$(docker images \
    | grep "${IMAGES_NAME_SUFFIX}" \
    | grep -E "${original_tag}|${backup_tag}" \
    | awk '{print $1";"$2}')

    for i in $images; do
      local image_and_tag=(${i//;/ })
      local image=${image_and_tag[0]}
      local tag=${image_and_tag[1]}
      local image_backup_file="${image//\//${DELIM_REGISTRY}}${DELIM_TAG}${tag}.tar.gz"

      echo "    ${image}:${tag}"
      docker save ${image}:${tag} \
      | gzip > ${backup_docker_images_dir}/${image_backup_file}
    done

    if [ -d ${BUILD_PATH}/images ]; then
      echo Saving docker images sources ...
      tar -czf "${backup_to_dir}/${image_sources_backup_file}" -C ${BUILD_PATH} images
    fi

    if [ -d ${BUILD_PATH}/pki ]; then
      echo Saving PKI ...
      tar -czf "${backup_to_dir}/${pki_backup_file}" -C ${BUILD_PATH} pki
    fi

    if [ -d ${DOCKER_DATA_PATH} ]; then
      echo Saving docker images data ...
      tar -czf "${backup_to_dir}/${docker_data_backup_file}" -C ${DOCKER_DATA_PATH} $(ls -A ${DOCKER_DATA_PATH})
    fi

    echo Coping control files ...
    cp "${PROJ_CONTROL_FILE}" "${backup_to_dir}"
    cp "${PROJ_COMPOSE_FILE}" "${backup_to_dir}"

    echo Backup ${DATE_TAG} done
}

while getopts "d?" opt; do
  case $opt in
    d)
      DETACH=
    ;;
  esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

case "$1" in
  up)
    shift
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      up \
      $DETACH \
      $@
  ;;
  down)
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      down
  ;;
  start)
    shift
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      start \
      $@
  ;;
  stop)
    shift
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      stop \
      $@
  ;;
  restart)
    shift
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      restart \
      $@
  ;;
  exec)
    shift
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      exec \
      $@
  ;;
  logs)
    shift
    docker-compose \
      --file ${DIR}/{{project}}.yml \
      --project-name {{project}} \
      logs \
      --follow \
      $@
  ;;
  clean)
    docker ps -a \
    | grep "{{registry_url}}{{project}}-" \
    | awk '{print $1}' \
    | xargs --no-run-if-empty docker rm --force --volumes
  ;;
  clean-images)
    docker images \
    | grep "{{registry_url}}{{project}}-" \
    | awk '{print $3}' \
    | xargs --no-run-if-empty docker rmi --force
  ;;
  backup)
    backup latest
  ;;
  *)
    echo "start | stop | logs | clean | clean-images"
  ;;
esac
