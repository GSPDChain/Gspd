#!/bin/bash

../build/bin/geth \
  --datadir ../gspd-data \
  --networkid 2025 \
  --mine \
  --miner.threads 4 \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545
