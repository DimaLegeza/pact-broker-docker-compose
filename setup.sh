#!/bin/bash

if ! [ -x "$(command -v docker)" ]; then
	sudo apt update
	sudo apt --assume-yes install docker.io
	sudo apt --assume-yes install docker-compose
	sudo usermod -aG docker ${USER}
	logout
fi
if [[ -z "$PACT_BROKER_BASIC_AUTH_USERNAME" ]]
then
	echo "Please set \$PACT_BROKER_BASIC_AUTH_USERNAME"
fi
if [[ -z "$PACT_BROKER_BASIC_AUTH_PASSWORD" ]]
then
        echo "Please set \$PACT_BROKER_BASIC_AUTH_PASSWORD"
fi

docker-compose up -d postgresql && sleep 5 && docker-compose up -d pact-broker
