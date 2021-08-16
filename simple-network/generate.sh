#!/bin/sh

../bin/cryptogen generate --config=./crypto-config.yaml

../bin/configtxgen -profile OneOrgOrdererGenesis -channelID system-channel -outputBlock ./config/genesis.block

../bin/configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/mychannel.tx -channelID mychannel

../bin/configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP

