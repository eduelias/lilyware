
# Edgware blockchain

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  

- [Summary](#summary)
- [Ether supply](#ether-supply)
- [BlockOne wallet](#blockone-wallet)
- [Access](#access)
  - [RPC](#rpc)
  - [Running a geth node](#running-a-geth-node)
    - [What the edgware-node.sh script does](#what-the-edgware-nodesh-script-does)
  - [Running a different Ethereum client](#running-a-different-ethereum-client)
  - [Statistics](#statistics)
  - [Explorer](#explorer)
- [Etiquette](#etiquette)
- [Support](#support)
- [Why "Edgware"?](#why-edgware)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Summary

*Edgware* is a private *Ethereum* blockchain that was first used during the *[HackETHon](https://hackethon.thomsonreuters.com/)*.

Block time should stay very small (i.e. transactions will be mined very quickly), because:
- the blockchain is very new
- genesis difficulty is very low
- mining happens only when there are transactions to process (Thomson Reuters is running the miners)

All our nodes on Edgware are running *geth 1.4.12-stable-421df866* (the head of the *master* branch at time of writing this). Compatibility with other versions or other *Ethereum* clients has not been verified.

## Ether supply
You can acquire up to 100 Ether for any account by sending a HTTP GET to (e.g. browse to):

https://blockone.thomsonreuters.com/dapp-services/v1/send/100/ether-to/0x53875825f820a5003d6c41c5ad6b2af6937d2132/on/edgware

.. obviously substituting the address you want to fund. After the transaction to transfer the Ether has been mined, the request will complete with an informative message.

## BlockOne wallet

Currently the BlockOne wallet only points to a single blockchain, Morden.

To switch https://blockone.thomsonreuters.com/wallet over to pointing to edgware, load [the wallet page](https://blockone.thomsonreuters.com/wallet), open the console (`CMD-ALT-i`) and enter these:

```
localStorage.setItem('DEFAULT_GETH_RPC_URL','https://blockone.int.thomsonreuters.com/edgware-chain-one-rpc/');
localStorage.setItem('TARGET_BLOCKCHAIN','edgware');
```

.. then reload the page.


N.B. This setting will survive page reloads / browser restarts.

To switch it back to the default (morden), load the wallet page, open the console (`CMD-ALT-i`) and enter these:
```
localStorage.removeItem('DEFAULT_GETH_RPC_URL');
localStorage.removeItem('TARGET_BLOCKCHAIN');
```

If you want a temporary setting (for the lifetime of the tab instead), make the above calls on sessionStorage rather than localStorage.

## Access
### RPC
JSON RPC ports are available at:
- https://blockone.int.thomsonreuters.com/edgware-chain-one-rpc
- https://blockone.int.thomsonreuters.com/edgware-chain-two-rpc

These are both hosted on AWS, but are **only accessible when connected to the TR internal network**.

### Running a geth node
Install or build a recent geth binary- v1.4.12 is recommended. Make sure it's in your path.

[Here is a zipfile of setup files](edgware.zip). Unzip it somewhere and run `./edgware-node.sh`. The invoked geth will connect to the Edgware blockchain and sync blocks, but not do any mining.

This works on OSX and should work on Linux. If you need support for other platforms your best bet is to put a request on the [BlockOne dev Slack channel](https://corptech.slack.com/messages/blockone-dev/).

#### What the edgware-node.sh script does

- Creates a new datadir for Edgware - `~/.ethereum-edgware-data-909`
- Copies the `static-nodes.json` file into it (this mechanism is more reliable than passing node addresses through the --bootnodes argument), to connect to the 2 cloud nodes mentioned above
- Initialises the genesis block from `genesis-block-edgware.json`
- Starts geth with:
   - no NAT traversal (speeds things up, presumably you don't need it)
   - the Edgware network ID (909)
   - `--bootnodes` argument set to junk (observed to be the *only* way to stop it reaching out to the public server addresses hardwired into geth)
   - open RPC port on all interfaces, with CORS domain '*' (so browsers don't complain about attaching to it)
   - interactive console


### Running a different Ethereum client
If you want to run a node other than geth, the important properties of this blockchain are:

- Homestead mode from block 0 (so this low-block-numbered blockchain behaves like Homestead)
- Network ID: 909
- Genesis block: see `genesis-block-edgware.json`
- Don't reach out to public (default) boot nodes- only try to connect to those listed in `static-nodes.json`
- No mining!

### Statistics
An eth-netstats server is running at https://blockone-edgware-stats.tr-api-services.net/ . The graphs seem to seize up a lot. The numbers are generally accurate.

### Explorer
An etherparty-explorer server is running at https://blockone-edgware-explorer.tr-api-services.net/ . It's a nice quick way to view info about ongoing transactions, account balances etc.

## Etiquette
Please don't run miners on Edgware. 
Thomson Reuters is running mining servers that will start mining when there are pending transactions, which will allow us to keep block time short, difficulty low and transaction processing latency low. So it's particularly important that you don't run nodes that mine continually- as this would cause difficulty to creep up til the blocktime target of 13 seconds is reached and the performance of everyone's DApps will suffer.

## Support
[BlockOne dev Slack channel](https://corptech.slack.com/messages/blockone-dev/)

## Why "Edgware"?
A London connection. Like "Morden", it's a place you might wake up if ever you fall asleep on the Northern Line.
