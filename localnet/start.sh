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

# pruning settings
# if pruning is defined
if [[ -z "${pruning}" ]]; then 
    pruning="--pruning=nothing"
else
    pruning=""
    sed -i 's/pruning = "default"/pruning = "custom"/g' $APP_CONFIG
    sed -i 's/pruning-keep-recent = "0"/pruning-keep-recent = "5"/g' $APP_CONFIG
    sed -i 's/pruning-interval = "0"/pruning-interval = "10"/g' $APP_CONFIG
fi

echo "running $CHAIN with extra flags $EXTRA_FLAGS"
echo "starting $CHAIN node in background ..."
echo "./"$CHAIND" start "$pruning" --rpc.unsafe --keyring-backend test --home "$DATA_DIR" >"$DATA_DIR"/node.log "$EXTRA_FLAGS""
./$CHAIND start $pruning --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log $EXTRA_FLAGS
