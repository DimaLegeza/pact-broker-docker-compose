#!/bin/bash

sudo apt update
sudo apt --assume-yes install docker.io
sudo apt --assume-yes install docker-compose

docker-compose up -d postgresql && sleep 5 && docker-compose up -d pact-broker
