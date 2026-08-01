# GSPD Wallet

## Create a New Wallet

```bash
build/bin/geth account new --datadir /path/to/gspd-data
```

## List Accounts

```bash
build/bin/geth account list --datadir /path/to/gspd-data
```

## Import Private Key

```bash
build/bin/geth account import privatekey.txt --datadir /path/to/gspd-data
```

## Start Node

```bash
build/bin/geth \
  --datadir /path/to/gspd-data \
  --networkid 2025 \
  --http \
  --http.port 18545
```

## Send Transaction

Use your wallet or JSON-RPC to send GSPD transactions.

## Backup

Always backup your keystore and password before using the wallet.
