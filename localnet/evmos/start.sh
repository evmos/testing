#!/bin/bash

DATA_DIR=/evmos
CONFIG=$DATA_DIR/config/config.toml

sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' $CONFIG
# Change to 1s to have the same default configuration as v9
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$CONFIG"

echo "running evmos with extra flags $EXTRA_FLAGS"
echo "starting evmos node $i in background ..."
./evmosd start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log $EXTRA_FLAGS
