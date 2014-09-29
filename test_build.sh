#!/bin/bash
set +x

VNCDISPLAY=80
PUBLICPORT="80$(printf "%02d" $VNCDISPLAY)"
echo "Using port: $PUBLICPORT"

#docker build -t guac --no-cache=true .
docker build -t guac .
docker run \
    -p "${PUBLICPORT}:8080" \
    -v "/tmp/guest-${PUBLICPORT}:/home/guest" \
    --rm=true -i --tty=true \
    -e "VNCDISPLAY=${VNCDISPLAY}" \
    guac
