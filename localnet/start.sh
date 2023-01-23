#!/bin/bash

# if chain not defined, defaults to evmos
if [[ -z "${CHAIN}" ]]; then CHAIN="evmos"; fi

CHAIND="$CHAIN"d
DATA_DIR=/$CHAIN
CONFIG=$DATA_DIR/config/config.toml
APP_CONFIG=$DATA_DIR/config/app.toml

sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
# Change to 1s to have the same default configuration as v9
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$CONFIG"
# make sure the localhost IP is 0.0.0.0
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' $CONFIG
sed -i 's/127.0.0.1/0.0.0.0/g' "$APP_CONFIG"

echo "running $CHAIN with extra flags $EXTRA_FLAGS"
echo "starting $CHAIN node $i in background ..."
./$CHAIND start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log $EXTRA_FLAGS
