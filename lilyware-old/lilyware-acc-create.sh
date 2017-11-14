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

NETWORKID=517
DATADIR=~/.ethereum-lilyware-data-$NETWORKID
MINEDIR=~/.ethereum-lilyware-mine-$NETWORKID

mkdir -p $DATADIR

if numAccounts=$($GETH --datadir $DATADIR account | grep -c Account) && [ $numAccounts -ne 0 ]; then
	echo "Inbuilt account already exists."
else
	inbuilt_account=$($GETH --datadir $DATADIR --password password account new | sed 's/^Address:..//;s/.$//')
	echo "Created account $inbuilt_account, will start geth with it unlocked."
	cp -r $DATADIR $MINEDIR
fi

cd ~/
find ./ -type f -name "genesis-block-lilyware.json" | xargs sed -i -e 's/2a3f5381c3bb6aa77029b48316e9c441675c9dd4/'${inbuilt_account}'/g'
find ./ -type f -name "lilyware-node-template.sh" | xargs sed -i -e 's/%WALLET%/'${inbuilt_account}'/g'
find ./ -type f -name "lilyware-miner.sh" | xargs sed -i -e 's/%WALLET%/'${inbuilt_account}'/g'
find ./ -type f -name "lilyware-node.sh" | xargs sed -i -e 's/%WALLET%/'${inbuilt_account}'/g'

export inbuilt_account