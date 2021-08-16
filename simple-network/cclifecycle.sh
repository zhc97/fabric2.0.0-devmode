#!/bin/sh
echo "package chaincode to tar.gz"
peer lifecycle chaincode package mycc.tar.gz --path chaincode/abstore/go/ --lang golang --label myccv1

echo "install the packaged chaincode to peer node"
peer lifecycle chaincode install mycc.tar.gz

echo "approve chaincode definition"
peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --channelID mychannel --name mycc --version 1 --init-required --package-id  myccv1:f3adce8d005f92570bdf1ca9af626b3f02498b74c660c651bb5d5b8a438bed00 --sequence 1

echo "commit the chaincode"
peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name mycc --version 1 --sequence 1 --init-required  --peerAddresses peer0.org1.example.com:7051

