#!/bin/bash

build/bin/geth \
  --datadir ./data \
  --networkid 2025 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
