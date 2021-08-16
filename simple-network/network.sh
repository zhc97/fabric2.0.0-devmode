#!/bin/bash

function Up(){
    set -e
    docker-compose -f docker-compose-simple.yaml up
}

function Down(){
    set +e
    docker-compose -f docker-compose-simple.yaml down -v
    docker volume rm $(docker volume ls -q)
    docker stop $(docker ps -aq)
    docker rmi -f $(docker images dev-* -q)
    docker rm -f $(docker ps -aq)
}

#function chaincode() {
#    peer chaincode install -p chaincodedev/chaincode/ht-fabric-chaincode -n mycc -v 0
#    peer chaincode instantiate -n mycc -v 0 -c '{"Args":[]}' -C myc
#}

if [ "$1" == "up" ]; then
    Up
elif [ "$1" == "down" ]; then
    Down
#elif [ "$1" == "chaincode" ]; then
#    chaincode
else
    echo "./network.sh up|down"
fi
