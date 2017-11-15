#!/bin/bash -e

GETH=geth

VERIFIED_VERSION=1.4.11-stable-fed692f6
if ! $GETH version | grep $VERIFIED_VERSION ; then
	echo ''
	echo '***********************************************************************'
    echo "N.B. This is only verified against $GETH version $VERIFIED_VERSION."
    echo -n 'You have '
    $GETH version | grep ^Version:
    echo "If you encounter problems please try $VERIFIED_VERSION instead."
	echo '***********************************************************************'
	echo ''
fi

NETWORKID=72
DATADIR=~/.ethereum-lilyware-data-$NETWORKID-%ID%
#ETHERBASE=0x8400264c2e3d5096aea709076af77d2e3fd3f169 #prd
ETHERBASE=0x%WALLET% #dev

mkdir -p $DATADIR
rm -rf $DATADIR/static-nodes.json
ln -f ../static-nodes.json $DATADIR

if numAccounts=$($GETH --datadir $DATADIR account | grep -c Account) && [ $numAccounts -ne 0 ]; then
	echo "Inbuilt account already exists."
else
	echo "===================================================="
	echo "Creating inbuilt account.."
	echo "===================================================="
	inbuilt_account=0x$($GETH --datadir $DATADIR --password password account new | sed 's/^Address:..//;s/.$//')
	echo "Created account $inbuilt_account, will start geth with it unlocked."
fi

$GETH --datadir $DATADIR init ../genesis-block-lilyware.json
$GETH --unlock 0 --password password --datadir $DATADIR --nat none --networkid $NETWORKID --bootnodes leave-me-alone --identity lilynode%ID%  --port 3030%ID% --rpc --rpcaddr 127.0.0.1 --rpcport 854%ID% --rpccorsdomain '*' --rpcapi "eth,web3" --etherbase $ETHERBASE &
