#!/bin/bash -e

#echo This script is only included for reference, so you can see how the miners work.
#exit

NETWORKID=72
DATADIR=~/.ethereum-lilyware-mine-$NETWORKID
#ETHERBASE=0x8400264c2e3d5096aea709076af77d2e3fd3f169 #prd
ETHERBASE=0x%WALLET% #dev

mkdir -p $DATADIR
ln -f ../static-nodes.json $DATADIR
geth --datadir $DATADIR init ../genesis-block-lilyware.json
geth --unlock 0 --password password --datadir $DATADIR --nat none --networkid $NETWORKID --bootnodes leave-me-alone --rpc --rpcaddr 0.0.0.0 --rpccorsdomain '*' --rpcport 8546 --port 31313 --etherbase $ETHERBASE js mineOnDemand.js
