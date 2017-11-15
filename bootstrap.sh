#!/bin/bash -e

case $(id -u) in
    0) sudo -u vagrant -i $0
esac

GETH_VERSION=1.5.5
GO_VERSION=1.7.5
GO_OS=linux
GO_ARCH=amd64
GO_ARCHIVE=go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
NETWORKID=72
DATADIR=~/.ethereum-lilyware-data-$NETWORKID

echo "APT::Acquire::Queue-Mode \"access\";\r\nAPT::Acquire::Retries 3;" | sudo tee --append /etc/apt/apt.conf.d/99parallel

sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable
sudo add-apt-repository -y ppa:ethereum/ethereum

sudo apt-get update
sudo apt-get -y upgrade

echo "------------------------------------------------------------------------"
echo "installing other dependencies"
sudo apt-get install -y vim git screen htop mc build-essential libgmp3-dev unzip curl golang ethereum

echo "------------------------------------------------------------------------"
echo "installing node 8"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

cd ~

echo "------------------------------------------------------------------------"
echo "installing pm2 (npm deamon)..."
sudo npm rebuild
#npm install bower -g
sudo npm install browserify -g --silent
sudo npm install -g pm2 --silent
sudo ln -s /usr/bin/nodejs /usr/local/bin/node
sudo npm install -g npm
cd ~

# echo "------------------------------------------------------------------------"
# echo "installing go-lang..."
# rm -rf ~/.temp && mkdir ~/.temp && cd ~/.temp
# wget --quiet https://storage.googleapis.com/golang/${GO_ARCHIVE} && sudo tar -C /usr/local -xzf ${GO_ARCHIVE}

# rm -rf $HOME/go && mkdir $HOME/go
# sudo echo "export PATH=/usr/local/go/bin:$PATH" >> ~/.profile
# sudo echo "export GOPATH=\$HOME/go" >> ~/.profile
# sudo echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.profile
# source ~/.profile

echo "------------------------------------------------------------------------"
echo "printing env..."
env

# echo "------------------------------------------------------------------------"
# echo "installing go-ethereum..."

# wget --quiet https://github.com/ethereum/go-ethereum/archive/v${GETH_VERSION}.zip
# unzip v${GETH_VERSION}.zip
# cd go-ethereum-${GETH_VERSION}
# make geth
# sudo rm -rf /usr/bin/geth && sudo ln -s ${PWD}/build/bin/geth /usr/bin/geth

echo "------------------------------------------------------------------------"
echo "installing lilyware-node..."

# get and install the lilyware node archive
cd ~/lilyware
#rm -rf lilyware.zip && cp /vagrant/lilyware.zip .
#unzip lilyware.zip
chmod +x lilyware-node.sh
chmod +x lilyware-miner.sh
chmod +x lilyware-acc-create.sh
mv static-nodes.json ../static-nodes.json
mv genesis-block-lilyware.json ../genesis-block-lilyware.json

echo "================================ CREATING ACCOUNT =========================================="
./lilyware-acc-create.sh
rm lilyware-acc-create.sh
echo "================================ DONE CREATE ACC! =========================================="

cd ~/
ln static-nodes.json $DATADIR

echo "------------------------------------------------------------------------"
echo "Creating node 1..."
NODENUMBER=1
cd ~
rm -rf lilyware-${NODENUMBER}
cp -R lilyware lilyware-${NODENUMBER}
cd lilyware-${NODENUMBER} 
rm -rf lilyware-node.sh 
rm -rf lilyware-miner.sh 
mv lilyware-node-template.sh lilyware-node.sh
find ./ -type f -name "lilyware-node.sh" | xargs sed -i -e 's/%ID%/'${NODENUMBER}'/g'
chmod +x lilyware-node.sh
cd ~/

# echo "------------------------------------------------------------------------"
# echo "Creating node 2..."
# NODENUMBER=2
# cd ~
# rm -rf lilyware-${NODENUMBER}
# cp -R lilyware lilyware-${NODENUMBER}
# cd lilyware-${NODENUMBER} 
# rm -rf lilyware-node.sh 
# rm -rf lilyware-miner.sh 
# mv lilyware-node-template.sh lilyware-node.sh
# find ./ -type f -name "lilyware-node.sh" | xargs sed -i -e 's/%ID%/'${NODENUMBER}'/g'
# chmod +x lilyware-node.sh
# cd ~/

cd lilyware
rm lilyware-node-template.sh
cd ~/
echo "------------------------------------------------------------------------"
echo " 			  			INSTALLING AUXILIARY TOOLS	  					  "
echo "------------------------------------------------------------------------"
echo "installing eth-explorer..."
git clone "https://github.com/etherparty/explorer"
cd ~/explorer
sed -i 's/-a localhost//g' package.json
sudo chown vagrant:vagrant ~ -R 
npm install --silent
#bower install --allow-root --slient
pm2 start npm -s --name "eth-explorer" -- start
cd ~

echo "------------------------------------------------------------------------"
echo "installing browser-solidity... (this may take a while)"
git clone "https://github.com/ethereum/browser-solidity/"
#sudo chown vagrant:vagrant ~ -R 
cd browser-solidity
npm install --silent
sudo npm run build --silent
pm2 start npm -s --name "browser-solidity" -- run serve
cd ~

cd ~/lilyware-1/
pm2 start --name "ETH1" ./lilyware-node.sh

cd ~/lilyware-2/
pm2 start --name "ETH2" ./lilyware-node.sh

pm2 list

echo "************************** OK! *****************************************"