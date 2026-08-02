## Go Ethereum

Official Golang implementation of the Ethereum protocol.

[![API Reference](
https://camo.githubusercontent.com/915b7be44ada53c290eb157634330494ebe3e30a/68747470733a2f2f676f646f632e6f72672f6769746875622e636f6d2f676f6c616e672f6764646f3f7374617475732e737667
)](https://pkg.go.dev/github.com/ethereum/go-ethereum?tab=doc)
[![Go Report Card](https://goreportcard.com/badge/github.com/ethereum/go-ethereum)](https://goreportcard.com/report/github.com/ethereum/go-ethereum)
[![Travis](https://travis-ci.com/ethereum/go-ethereum.svg?branch=master)](https://travis-ci.com/ethereum/go-ethereum)
[![Discord](https://img.shields.io/badge/discord-join%20chat-blue.svg)](https://discord.gg/nthXNEv)

Automated builds are available for stable releases and the unstable master branch. Binary
archives are published at https://geth.ethereum.org/downloads/.

## Building the source

For prerequisites and detailed build instructions please read the [Installation Instructions](https://geth.ethereum.org/docs/install-and-build/installing-geth).

Building `geth` requires both a Go (version 1.16 or later) and a C compiler. You can install
them using your favourite package manager. Once the dependencies are installed, run

```shell
make geth
```

or, to build the full suite of utilities:

```shell
make all
```

## Executables

The go-ethereum project comes with several wrappers/executables found in the `cmd`
directory.

|    Command    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| :-----------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  **`geth`**   | Our main Ethereum CLI client. It is the entry point into the Ethereum network (main-, test- or private net), capable of running as a full node (default), archive node (retaining all historical state) or a light node (retrieving data live). It can be used by other processes as a gateway into the Ethereum network via JSON RPC endpoints exposed on top of HTTP, WebSocket and/or IPC transports. `geth --help` and the [CLI page](https://geth.ethereum.org/docs/interface/command-line-options) for command line options.          |
|   `clef`    | Stand-alone signing tool, which can be used as a backend signer for `geth`.  |
|   `devp2p`    | Utilities to interact with nodes on the networking layer, without running a full blockchain. |
|   `abigen`    | Source code generator to convert Ethereum contract definitions into easy to use, compile-time type-safe Go packages. It operates on plain [Ethereum contract ABIs](https://docs.soliditylang.org/en/develop/abi-spec.html) with expanded functionality if the contract bytecode is also available. However, it also accepts Solidity source files, making development much more streamlined. Please see our [Native DApps](https://geth.ethereum.org/docs/dapp/native-bindings) page for details. |
|  `bootnode`   | Stripped down version of our Ethereum client implementation that only takes part in the network node discovery protocol, but does not run any of the higher level application protocols. It can be used as a lightweight bootstrap node to aid in finding peers in private networks.                                                                                                                                                                                                                                                                 |
|     `evm`     | Developer utility version of the EVM (Ethereum Virtual Machine) that is capable of running bytecode snippets within a configurable environment and execution mode. Its purpose is to allow isolated, fine-grained debugging of EVM opcodes (e.g. `evm --code 60ff60ff --debug run`).                                                                                                                                                                                                                                                                     |
|   `rlpdump`   | Developer utility tool to convert binary RLP ([Recursive Length Prefix](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp)) dumps (data encoding used by the Ethereum protocol both network as well as consensus wise) to user-friendlier hierarchical representation (e.g. `rlpdump --hex CE0183FFFFFFC4C304050583616263`).                                                                                                                                                                                                                                 |
|   `puppeth`   | a CLI wizard that aids in creating a new Ethereum network.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |

## Running `geth`

Going through all the possible command line flags is out of scope here (please consult our
[CLI Wiki page](https://geth.ethereum.org/docs/interface/command-line-options)),
but we've enumerated a few common parameter combos to get you up to speed quickly
on how you can run your own `geth` instance.

### Hardware Requirements

Minimum:

* CPU with 2+ cores
* 4GB RAM
* 1TB free storage space to sync the Mainnet
* 8 MBit/sec download Internet service

Recommended:

* Fast CPU with 4+ cores
* 16GB+ RAM
* High Performance SSD with at least 1TB free space
* 25+ MBit/sec download Internet service

### Full node on the main Ethereum network

By far the most common scenario is people wanting to simply interact with the Ethereum
network: create accounts; transfer funds; deploy and interact with contracts. For this
particular use-case the user doesn't care about years-old historical data, so we can
sync quickly to the current state of the network. To do so:

```shell
$ geth console
```

This command will:
 * Start `geth` in snap sync mode (default, can be changed with the `--syncmode` flag),
   causing it to download more data in exchange for avoiding processing the entire history
   of the Ethereum network, which is very CPU intensive.
 * Start up `geth`'s built-in interactive [JavaScript console](https://geth.ethereum.org/docs/interface/javascript-console),
   (via the trailing `console` subcommand) through which you can interact using [`web3` methods](https://github.com/ChainSafe/web3.js/blob/0.20.7/DOCUMENTATION.md) 
   (note: the `web3` version bundled within `geth` is very old, and not up to date with official docs),
   as well as `geth`'s own [management APIs](https://geth.ethereum.org/docs/rpc/server).
   This tool is optional and if you leave it out you can always attach to an already running
   `geth` instance with `geth attach`.

### A Full node on the Görli test network

Transitioning towards developers, if you'd like to play around with creating Ethereum
contracts, you almost certainly would like to do that without any real money involved until
you get the hang of the entire system. In other words, instead of attaching to the main
network, you want to join the **test** network with your node, which is fully equivalent to
the main network, but with play-Ether only.

```shell
$ geth --goerli console
```

The `console` subcommand has the exact same meaning as above and they are equally
useful on the testnet too. Please, see above for their explanations if you've skipped here.

Specifying the `--goerli` flag, however, will reconfigure your `geth` instance a bit:

 * Instead of connecting the main Ethereum network, the client will connect to the Görli
   test network, which uses different P2P bootnodes, different network IDs and genesis
   states.
 * Instead of using the default data directory (`~/.ethereum` on Linux for example), `geth`
   will nest itself one level deeper into a `goerli` subfolder (`~/.ethereum/goerli` on
   Linux). Note, on OSX and Linux this also means that attaching to a running testnet node
   requires the use of a custom endpoint since `geth attach` will try to attach to a
   production node endpoint by default, e.g.,
   `geth attach <datadir>/goerli/geth.ipc`. Windows users are not affected by
   this.

*Note: Although there are some internal protective measures to prevent transactions from
crossing over between the main network and test network, you should make sure to always
use separate accounts for play-money and real-money. Unless you manually move
accounts, `geth` will by default correctly separate the two networks and will not make any
accounts available between them.*

### Full node on the Rinkeby test network

Go Ethereum also supports connecting to the older proof-of-authority based test network
called [*Rinkeby*](https://www.rinkeby.io) which is operated by members of the community.

```shell
$ geth --rinkeby console
```

### Full node on the Ropsten test network

In addition to Görli and Rinkeby, Geth also supports the ancient Ropsten testnet. The
Ropsten test network is based on the Ethash proof-of-work consensus algorithm. As such,
it has certain extra overhead and is more susceptible to reorganization attacks due to the
network's low difficulty/security.

```shell
$ geth --ropsten console
```

*Note: Older Geth configurations store the Ropsten database in the `testnet` subdirectory.*

### Configuration

As an alternative to passing the numerous flags to the `geth` binary, you can also pass a
configuration file via:

```shell
$ geth --config /path/to/your_config.toml
```

To get an idea how the file should look like you can use the `dumpconfig` subcommand to
export your existing configuration:

```shell
$ geth --your-favourite-flags dumpconfig
```

*Note: This works only with `geth` v1.6.0 and above.*

#### Docker quick start

One of the quickest ways to get Ethereum up and running on your machine is by using
Docker:

```shell
docker run -d --name ethereum-node -v /Users/alice/ethereum:/root \
           -p 8545:8545 -p 30303:30303 \
           ethereum/client-go
```

This will start `geth` in snap-sync mode with a DB memory allowance of 1GB just as the
above command does.  It will also create a persistent volume in your home directory for
saving your blockchain as well as map the default ports. There is also an `alpine` tag
available for a slim version of the image.

Do not forget `--http.addr 0.0.0.0`, if you want to access RPC from other containers
and/or hosts. By default, `geth` binds to the local interface and RPC endpoints are not
accessible from the outside.

### Programmatically interfacing `geth` nodes

As a developer, sooner rather than later you'll want to start interacting with `geth` and the
Ethereum network via your own programs and not manually through the console. To aid
this, `geth` has built-in support for a JSON-RPC based APIs ([standard APIs](https://ethereum.github.io/execution-apis/api-documentation/)
and [`geth` specific APIs](https://geth.ethereum.org/docs/rpc/server)).
These can be exposed via HTTP, WebSockets and IPC (UNIX sockets on UNIX based
platforms, and named pipes on Windows).

The IPC interface is enabled by default and exposes all the APIs supported by `geth`,
whereas the HTTP and WS interfaces need to manually be enabled and only expose a
subset of APIs due to security reasons. These can be turned on/off and configured as
you'd expect.

HTTP based JSON-RPC API options:

  * `--http` Enable the HTTP-RPC server
  * `--http.addr` HTTP-RPC server listening interface (default: `localhost`)
  * `--http.port` HTTP-RPC server listening port (default: `8545`)
  * `--http.api` API's offered over the HTTP-RPC interface (default: `eth,net,web3`)
  * `--http.corsdomain` Comma separated list of domains from which to accept cross origin requests (browser enforced)
  * `--ws` Enable the WS-RPC server
  * `--ws.addr` WS-RPC server listening interface (default: `localhost`)
  * `--ws.port` WS-RPC server listening port (default: `8546`)
  * `--ws.api` API's offered over the WS-RPC interface (default: `eth,net,web3`)
  * `--ws.origins` Origins from which to accept websockets requests
  * `--ipcdisable` Disable the IPC-RPC server
  * `--ipcapi` API's offered over the IPC-RPC interface (default: `admin,debug,eth,miner,net,personal,txpool,web3`)
  * `--ipcpath` Filename for IPC socket/pipe within the datadir (explicit paths escape it)

You'll need to use your own programming environments' capabilities (libraries, tools, etc) to
connect via HTTP, WS or IPC to a `geth` node configured with the above flags and you'll
need to speak [JSON-RPC](https://www.jsonrpc.org/specification) on all transports. You
can reuse the same connection for multiple requests!

**Note: Please understand the security implications of opening up an HTTP/WS based
transport before doing so! Hackers on the internet are actively trying to subvert
Ethereum nodes with exposed APIs! Further, all browser tabs can access locally
running web servers, so malicious web pages could try to subvert locally available
APIs!**

### Operating a private network

Maintaining your own private network is more involved as a lot of configurations taken for
granted in the official networks need to be manually set up.

#### Defining the private genesis state

First, you'll need to create the genesis state of your networks, which all nodes need to be
aware of and agree upon. This consists of a small JSON file (e.g. call it `genesis.json`):

```json
{
  "config": {
    "chainId": <arbitrary positive integer>,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0
  },
  "alloc": {},
  "coinbase": "0x0000000000000000000000000000000000000000",
  "difficulty": "0x20000",
  "extraData": "",
  "gasLimit": "0x2fefd8",
  "nonce": "0x0000000000000042",
  "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
```

The above fields should be fine for most purposes, although we'd recommend changing
the `nonce` to some random value so you prevent unknown remote nodes from being able
to connect to you. If you'd like to pre-fund some accounts for easier testing, create
the accounts and populate the `alloc` field with their addresses.

```json
"alloc": {
  "0x0000000000000000000000000000000000000001": {
    "balance": "111111111"
  },
  "0x0000000000000000000000000000000000000002": {
    "balance": "222222222"
  }
}
```

With the genesis state defined in the above JSON file, you'll need to initialize **every**
`geth` node with it prior to starting it up to ensure all blockchain parameters are correctly
set:

```shell
$ geth init path/to/genesis.json
```

#### Creating the rendezvous point

With all nodes that you want to run initialized to the desired genesis state, you'll need to
start a bootstrap node that others can use to find each other in your network and/or over
the internet. The clean way is to configure and run a dedicated bootnode:

```shell
$ bootnode --genkey=boot.key
$ bootnode --nodekey=boot.key
```

With the bootnode online, it will display an [`enode` URL](https://ethereum.org/en/developers/docs/networking-layer/network-addresses/#enode)
that other nodes can use to connect to it and exchange peer information. Make sure to
replace the displayed IP address information (most probably `[::]`) with your externally
accessible IP to get the actual `enode` URL.

*Note: You could also use a full-fledged `geth` node as a bootnode, but it's the less
recommended way.*

#### Starting up your member nodes

With the bootnode operational and externally reachable (you can try
`telnet <ip> <port>` to ensure it's indeed reachable), start every subsequent `geth`
node pointed to the bootnode for peer discovery via the `--bootnodes` flag. It will
probably also be desirable to keep the data directory of your private network separated, so
do also specify a custom `--datadir` flag.

```shell
$ geth --datadir=path/to/custom/data/folder --bootnodes=<bootnode-enode-url-from-above>
```

*Note: Since your network will be completely cut off from the main and test networks, you'll
also need to configure a miner to process transactions and create new blocks for you.*

#### Running a private miner

Mining on the public Ethereum network is a complex task as it's only feasible using GPUs,
requiring an OpenCL or CUDA enabled `ethminer` instance. For information on such a
setup, please consult the [EtherMining subreddit](https://www.reddit.com/r/EtherMining/)
and the [ethminer](https://github.com/ethereum-mining/ethminer) repository.

In a private network setting, however a single CPU miner instance is more than enough for
practical purposes as it can produce a stable stream of blocks at the correct intervals
without needing heavy resources (consider running on a single thread, no need for multiple
ones either). To start a `geth` instance for mining, run it with all your usual flags, extended
by:

```shell
$ geth <usual-flags> --mine --miner.threads=1 --miner.etherbase=0x0000000000000000000000000000000000000000
```

Which will start mining blocks and transactions on a single CPU thread, crediting all
proceedings to the account specified by `--miner.etherbase`. You can further tune the mining
by changing the default gas limit blocks converge to (`--miner.targetgaslimit`) and the price
transactions are accepted at (`--miner.gasprice`).

## Contribution

Thank you for considering to help out with the source code! We welcome contributions
from anyone on the internet, and are grateful for even the smallest of fixes!

If you'd like to contribute to go-ethereum, please fork, fix, commit and send a pull request
for the maintainers to review and merge into the main code base. If you wish to submit
more complex changes though, please check up with the core devs first on [our Discord Server](https://discord.gg/invite/nthXNEv)
to ensure those changes are in line with the general philosophy of the project and/or get
some early feedback which can make both your efforts much lighter as well as our review
and merge procedures quick and simple.

Please make sure your contributions adhere to our coding guidelines:

 * Code must adhere to the official Go [formatting](https://golang.org/doc/effective_go.html#formatting)
   guidelines (i.e. uses [gofmt](https://golang.org/cmd/gofmt/)).
 * Code must be documented adhering to the official Go [commentary](https://golang.org/doc/effective_go.html#commentary)
   guidelines.
 * Pull requests need to be based on and opened against the `master` branch.
 * Commit messages should be prefixed with the package(s) they modify.
   * E.g. "eth, rpc: make trace configs optional"

Please see the [Developers' Guide](https://geth.ethereum.org/docs/developers/devguide)
for more details on configuring your environment, managing project dependencies, and
testing procedures.

## License

The go-ethereum library (i.e. all code outside of the `cmd` directory) is licensed under the
[GNU Lesser General Public License v3.0](https://www.gnu.org/licenses/lgpl-3.0.en.html),
also included in our repository in the `COPYING.LESSER` file.

The go-ethereum binaries (i.e. all code inside of the `cmd` directory) is licensed under the
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html), also
included in our repository in the `COPYING` file.


# GSPD

GSPD is an open-source blockchain project focused on building a decentralized ecosystem with native mining, wallet, explorer, DEX, and cross-chain interoperability.

## Project Status

⚠️ The project is currently under active development.

- Public mining: Not ready
- TCP/P2P network: Under development
- Wallet: Coming soon
- DEX: Coming soon
- Mainnet: In progress

## Repository

https://github.com/GSPDChain/Gspd

## Ecosystem

- Native GSPD Mainnet
- GSPD Explorer
- GSPD RPC
- GWBTC Bridge
- Wallet (Coming Soon)
- DEX (Coming Soon)

## Support Development

If you would like to support the development of GSPD, you can donate Bitcoin to:

**Bitcoin (BTC)**

`bc1qxyqmr4wqm39789qz8jwe7yf3afd46ucucdwr3z`

Every contribution helps us continue developing the GSPD ecosystem.

Thank you for your support.

## License

This project is open source.

## Initialize GSPD Mainnet

```bash
geth init genesis/mainnet.json --datadir /path/to/gspd-data
```

## Start GSPD Node

```bash
geth \
  --datadir /path/to/gspd-data \
  --networkid 2025 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

## Start Mining (Example)

```bash
geth \
  --datadir /path/to/gspd-data \
  --networkid 2025 \
  --mine \
  --miner.threads 4 \
  --unlock YOUR_WALLET_ADDRESS \
  --password password.txt
```


# GSPD

GSPD is an open-source Proof-of-Work blockchain based on Go Ethereum. The project is designed to provide a decentralized network with native mining, RPC, wallet support, explorer, GRC20 smart contracts, and a decentralized exchange (DEX).

## Features

- Proof-of-Work (PoW)
- Native GSPD Coin
- GRC20 Smart Contracts
- JSON-RPC API
- Peer-to-Peer Network
- Mining Support
- Explorer Support
- Wallet Support
- DEX Support
- Liquidity Pair Creation

## Repository

https://github.com/GSPDChain/Gspd

## Requirements

- Go 1.20+
- Linux, macOS, or Windows

## Build

```bash
make geth
```

The binary will be created in:

```text
build/bin/geth
```

## Initialize GSPD Mainnet

```bash
build/bin/geth init genesis/mainnet.json --datadir /path/to/gspd-data
```

Example:

```bash
build/bin/geth init genesis/mainnet.json --datadir /root/gspd-data
```

## Start GSPD Node

```bash
build/bin/geth \
  --datadir /path/to/gspd-data \
  --networkid 2025 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

## Start Mining

```bash
build/bin/geth \
  --datadir /path/to/gspd-data \
  --networkid 2025 \
  --mine \
  --miner.threads 4 \
  --unlock YOUR_WALLET_ADDRESS \
  --password password.txt
```

## Bootnode

```bash
build/bin/bootnode
```

## JSON RPC

Default RPC:

```
http://127.0.0.1:18545
```

## Chain Information

- Network Name: GSPD Mainnet
- Chain ID: 2025
- Consensus: Proof-of-Work

## Genesis

The official genesis block is located at:

```
genesis/mainnet.json
```

## License

This project is released under the GNU Lesser General Public License v3.0.


## Network Information

- Network Name: GSPD Mainnet
- Chain ID: 2025
- Consensus: Ethash (Proof-of-Work)

### Official Bootstrap Node

```
enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303
```

### Genesis Hash

```
0x4ac0c9019e184b0ed333b977bb246084aadcf68d478618a2a33a2dd35e07afbb
```


# GSPD

GSPD is an open-source Proof-of-Work blockchain based on Go Ethereum. The project provides a decentralized blockchain with native mining, GRC20 smart contracts, RPC, wallet support, explorer, and decentralized exchange (DEX).

## Features

- Proof-of-Work (Ethash)
- Native GSPD Coin
- GRC20 Smart Contracts
- JSON-RPC API
- Peer-to-Peer Network
- Native Mining
- Explorer
- Wallet
- DEX
- Liquidity Pair Creation

## Build

```bash
make geth
```

Binary output:

```text
build/bin/geth
```

## Initialize GSPD Mainnet

```bash
build/bin/geth init genesis/mainnet.json --datadir /path/to/gspd-data
```

Example:

```bash
build/bin/geth init genesis/mainnet.json --datadir /root/gspd-data
```

## Run GSPD Node

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

## Mining

```bash
build/bin/geth \
  --mine \
  --miner.threads 4
```

## Network Information

| Item | Value |
|------|-------|
| Network | GSPD Mainnet |
| Chain ID | 2025 |
| Network ID | 2025 |
| Consensus | Ethash (Proof-of-Work) |

## Genesis Hash

```
0x4ac0c9019e184b0ed333b977bb246084aadcf68d478618a2a33a2dd35e07afbb
```

## Official Bootstrap Node

```
enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303
```

## Genesis

```
genesis/mainnet.json
```

## Repository

https://github.com/GSPDChain/Gspd

## License

GNU Lesser General Public License v3.0


## Quick Start

### Clone Repository

```bash
git clone https://github.com/GSPDChain/Gspd.git
cd Gspd
```

### Build Geth

```bash
make geth
```

### Initialize GSPD Mainnet

```bash
./build/bin/geth init genesis/mainnet.json --datadir ./gspd-data
```

### Run GSPD Node

```bash
./build/bin/geth \
  --datadir ./gspd-data \
  --networkid 2025 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```


# GSPD Chain

GSPD Chain adalah blockchain Proof-of-Work yang memiliki ekosistem lengkap untuk Wallet, Explorer, API, DEX, Exchange, RPC, Mining Pool, dan Bridge.

## Repositories

| Repository | Description |
|------------|-------------|
| Gspd | Blockchain Node |
| gspd-api | Backend API |
| gspd-wallet | Web Wallet |
| gspd-explorer | Blockchain Explorer |
| gspd-contracts | Smart Contracts |
| gspd-rpc | RPC Website |
| gspd-dex | Decentralized Exchange |
| gspd-exchange | Centralized Exchange Backend |
| gspd-proxy | GRC Proxy |
| gspd-cloudflare | Cloudflare Tunnel Configuration |

## Architecture

```
Wallet
   │
Explorer
   │
DEX
   │
Exchange
   │
   ▼
GSPD API
   │
   ▼
GRC Proxy
   │
   ▼
Geth Node
   │
   ▼
GSPD Blockchain
```

## Installation

1. Install GSPD Node.
2. Start Geth.
3. Start GRC Proxy.
4. Start Cloudflare Tunnel.
5. Start GSPD API.
6. Start Mining Pool.
7. Open Wallet or Explorer.

## Documentation

See the documentation inside each repository.

## License

MIT License

# GSPD Chain

GSPD Chain adalah blockchain Proof-of-Work (PoW) yang menyediakan ekosistem lengkap untuk membangun aplikasi blockchain, wallet, explorer, RPC, DEX, exchange, smart contracts, mining pool, dan bridge.

## Features

- Proof-of-Work (Ethash)
- 21,000,000 Maximum Supply
- Geth-based Blockchain
- JSON-RPC Support
- Mining Pool
- Block Explorer
- Web Wallet
- Decentralized Exchange (DEX)
- Bridge Infrastructure
- REST API
- Cloudflare Tunnel Support

## Components

| Component | Description |
|----------|-------------|
| GSPD Blockchain | Core blockchain node |
| GSPD API | Backend REST API |
| GSPD Wallet | Web wallet |
| GSPD Explorer | Blockchain explorer |
| GSPD RPC | Public RPC interface |
| GSPD DEX | Decentralized exchange |
| GSPD Exchange | Exchange backend |
| GSPD Contracts | Smart contracts |
| GSPD Proxy | RPC/GRC proxy |
| GSPD Cloudflare | Cloudflare Tunnel configuration |

## Start Order

Start services in the following order:

### 1. Start GSPD Blockchain

```bash
cd /root/go-ethereum-gspd-bitcoin

# Start Geth using your GSPD configuration
```

### 2. Start GRC Proxy

```bash
cd /root/backup/gspd-chain
node grc-proxy.js
```

### 3. Start Cloudflare Tunnel

```bash
cloudflared tunnel --config /root/.cloudflared/config.yml run
```

### 4. Start GSPD API

```bash
cd ~/gspd-api
node index.js
```

### 5. Start Mining Pool

```bash
cd ~/gspd-api/gspd-pool

node api/server.js
node stratum/server.js
```

## Architecture

```
Wallet
   │
Explorer
   │
DEX
   │
Exchange
   │
   ▼
GSPD API
   │
   ▼
GRC Proxy
   │
   ▼
Geth Node
   │
   ▼
GSPD Blockchain
```

## Related Projects

- **GSPD Blockchain** — https://github.com/GSPDChain/Gspd
- **GSPD API** — https://github.com/GSPDChain/gspd-api
- **GSPD Wallet** — https://github.com/GSPDChain/gspd-wallet
- **GSPD Explorer** — https://github.com/GSPDChain/gspd-explorer
- **GSPD RPC** — https://github.com/GSPDChain/gspd-rpc
- **GSPD DEX** — https://github.com/GSPDChain/gspd-dex
- **GSPD Exchange** — https://github.com/GSPDChain/gspd-exchange
- **GSPD Smart Contracts** — https://github.com/GSPDChain/gspd-contracts
- **GSPD Proxy** — https://github.com/GSPDChain/gspd-proxy
- **GSPD Cloudflare** — https://github.com/GSPDChain/gspd-cloudflare

## Documentation

See the documentation provided in each repository.

## License

MIT License


Ya, untuk public miner GSPD, yang benar adalah dokumentasi yang kedua, tetapi ada satu hal penting yang perlu ditambahkan agar peer bisa saling menemukan.
Miner publik akan menjalankan node seperti ini:
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
Lalu jika ingin ikut mining:
miner.start(4)
atau menjalankan dengan:
--mine --miner.threads 4
Namun, agar node mereka benar-benar bergabung ke jaringan GSPD, dokumentasi sebaiknya juga menyertakan bootnode resmi. Misalnya:
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --bootnodes "enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303" \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
Dengan begitu, saat miner menjalankan node:
Mereka akan terhubung ke bootnode GSPD.
Node akan menyinkronkan blockchain.
Setelah sinkron, mereka bisa mulai mining dan blok yang ditemukan akan disebarkan ke jaringan.
Mengenai masalah peerCount 0
Kalau bootnode milikmu sendiri kadang menunjukkan:
net.peerCount
0
padahal sebelumnya sempat menjadi 1 atau 2, berarti ada kemungkinan:
Node lain belum aktif terus-menerus.
Discovery belum menemukan peer yang stabil.
Port 30303 TCP/UDP di salah satu sisi belum benar-benar terbuka.
Node lain selesai sinkron lalu disconnect.
Bootnode memang bisa sesekali memiliki peerCount 0 jika tidak ada node lain yang sedang online. Yang penting, ketika miner publik mulai menjalankan node menggunakan bootnode tersebut, mereka seharusnya dapat menemukan jaringan dan saling terhubung.


Berikut pembaruan README.md yang dapat langsung menggantikan bagian Run GSPD Node dan Mining.
# GSPD

GSPD is an open-source Proof-of-Work blockchain based on Go Ethereum. The project provides a decentralized blockchain with native mining, GRC20 smart contracts, RPC, wallet support, explorer, and decentralized exchange (DEX).

## Features

- Proof-of-Work (Ethash)
- Native GSPD Coin
- GRC20 Smart Contracts
- JSON-RPC API
- Peer-to-Peer Network
- Native Mining
- Explorer
- Wallet
- DEX
- Liquidity Pair Creation

---

# Build

```bash
make geth
```

Binary output:

```text
build/bin/geth
```

---

# Initialize GSPD Mainnet

```bash
build/bin/geth init genesis/mainnet.json --datadir /path/to/gspd-data
```

Example:

```bash
build/bin/geth init genesis/mainnet.json --datadir /root/gspd-data
```

---

# Run GSPD Node

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

---

# Join the GSPD Public Network

To connect directly to the public GSPD network, start the node with the official bootstrap node.

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --bootnodes "enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303" \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

When started with the official bootnode:

- The node connects to the GSPD peer-to-peer network.
- The blockchain begins synchronizing automatically.
- After synchronization is complete, mining can be started.
- Newly mined blocks are propagated to the entire GSPD network.

---

# Mining

Start mining from the JavaScript console:

```javascript
miner.start(4)
```

Or launch the node with mining enabled:

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --bootnodes "enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303" \
  --mine \
  --miner.threads 4
```

---

# Network Information

| Item | Value |
|------|-------|
| Network | GSPD Mainnet |
| Chain ID | 2025 |
| Network ID | 2025 |
| Consensus | Ethash (Proof-of-Work) |

### Genesis Hash

```
0x4ac0c9019e184b0ed333b977bb246084aadcf68d478618a2a33a2dd35e07afbb
```

### Official Bootstrap Node

```
enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303
```

---

# Peer Discovery

It is normal for a node to occasionally report:

```javascript
net.peerCount
0
```

A temporary peer count of zero does not necessarily indicate a problem.

Possible reasons include:

- No other public nodes are currently online.
- Peer discovery has not yet found stable peers.
- TCP/UDP port 30303 is not reachable.
- Remote peers finished synchronization and disconnected.

As more public miners run GSPD nodes using the official bootstrap node, peer discovery will improve and nodes will automatically connect to one another.

---

# Genesis

```
genesis/mainnet.json
```

---

# Repository

https://github.com/GSPDChain/Gspd

---

# License

GNU Lesser General Public License v3.0
Versi ini lebih lengkap untuk miner publik karena menjelaskan:
cara menjalankan node,
cara bergabung ke jaringan melalui bootnode resmi,
cara mulai mining,
dan penjelasan mengenai net.peerCount yang kadang menjadi 0 agar pengguna tidak mengira node mereka bermasalah.

## Run GSPD Node

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

---

## Join the GSPD Public Network

To connect to the public GSPD network, use the official bootstrap node.

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --port 30303 \
  --bootnodes "enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303" \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
```

When using the official bootnode:

- Connects to the GSPD peer-to-peer network.
- Synchronizes the blockchain automatically.
- Ready to start mining after synchronization.
- Mined blocks are propagated across the GSPD network.

---

## Mining

Start mining from the JavaScript console:

```javascript
miner.start(4)
```

Or start mining directly:

```bash
build/bin/geth \
  --datadir /root/gspd-data \
  --networkid 2025 \
  --bootnodes "enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303" \
  --mine \
  --miner.threads 4
```

---

## Official Bootstrap Node

```
enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303
```

---

## Peer Discovery

Occasionally you may see:

```javascript
net.peerCount
0
```

This is normal for a public network and does not necessarily indicate a problem.

Possible reasons include:

- No other public nodes are currently online.
- Peer discovery is still searching for peers.
- TCP/UDP port 30303 is not reachable.
- Remote peers have disconnected after synchronization.

As more public miners join the network using the official bootstrap node, peer connectivity will improve automatically.
