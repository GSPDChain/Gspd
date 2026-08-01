#!/bin/bash

../build/bin/geth \
  --datadir ../gspd-data \
  --networkid 2025 \
  --port 30303 \
  --bootnodes "enode://ee973b2637cc86181df92e20342d7592130af06ef7551673df661275a21297c165fe16ab68e77030e619f8adc1d29b38f923e1e92de1e8a5b7e18ff29f0fd22c@182.8.130.113:30303" \
  --http \
  --http.addr 127.0.0.1 \
  --http.port 18545 \
  --http.api admin,eth,net,web3,personal \
  console
