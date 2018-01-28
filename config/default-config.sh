MTLS=False
TOKEN=False
WORKERS=1
CLIENTS=1

MISSFIRE=.
BANK=MicroBank

MISSFIRE_SERVICES="$MISSFIRE/services"
BANK_SERVICES="$BANK/services"

MISSFIRE_COMMONS="$MISSFIRE/MiSSFire_client_commons"
BANK_COMMONS="$BANK_SERVICES/common_files"

MISSFIRE_CLIENT_DOCKER_IMAGE="$MISSFIRE/docker_image_template/MiSSFire_client"
MISSFIRE_SERVICES_DOCKER_IMAGE="$MISSFIRE/docker_image_template/MiSSFire_services"

DOCKER_YML="$MISSFIRE/docker-compose.yml_"
DOCKER_YML_ORIGINAL="$MISSFIRE/docker-compose.yml_original"
