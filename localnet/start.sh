#!/bin/bash

# if chain not defined, defaults to evmos
if [[ -z "${CHAIN}" ]]; then CHAIN="evmos"; fi

CHAIN_ID="$CHAIN"_9000-1
CHAIND="$CHAIN"d
DATA_DIR=/$CHAIN
CONFIG=$DATA_DIR/config/config.toml
APP_CONFIG=$DATA_DIR/config/app.toml

sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
sed -i 's/enable-indexer = false/enable-indexer = true/g' $APP_CONFIG
perl -i -0pe 's/# Enable defines if the API server should be enabled.\nenable = false/# Enable defines if the API server should be enabled.\nenable = true/' $APP_CONFIG

sed -i 's/timeout_commit = "5s"/timeout_commit = "3s"/g' "$CONFIG"
# make sure the localhost IP is 0.0.0.0
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' "$CONFIG"
sed -i 's/127.0.0.1/0.0.0.0/g' "$APP_CONFIG"
sed -i 's/localhost/0.0.0.0/g' "$APP_CONFIG"

# disable state sync
sed -i.bak 's/enable = true/enable = false/g' "$CONFIG"

# sed -i.bak 's/db_backend = "goleveldb"/db_backend = "rocksdb"/g' "$CONFIG"

# Change max_subscription to for bots workers
# toml-cli set $CONFIG rpc.max_subscriptions_per_client 500
# Change max_subscription to for bots workers
sed -i.bak 's/max_subscriptions_per_client = 5/max_subscriptions_per_client = 500/g' "$CONFIG"

sed -i.bak 's/indexer = "null"/indexer = "kv"/g' "$CONFIG"
sed -i.bak 's/namespace = "tendermint"/namespace = "cometbft"/g' "$CONFIG"

# pruning settings
# if pruning is defined
if [[ -z "${pruning}" ]]; then 
    pruning="--pruning=nothing"
else
    pruning=""
    sed -i 's/pruning = "default"/pruning = "custom"/g' "$APP_CONFIG"
    sed -i 's/pruning-keep-recent = "0"/pruning-keep-recent = "5"/g' "$APP_CONFIG"
    sed -i 's/pruning-interval = "0"/pruning-interval = "10"/g' "$APP_CONFIG"
fi

echo "running $CHAIN with extra flags $EXTRA_FLAGS"
echo "starting $CHAIN node in background ..."
echo "./"$CHAIND" start "$pruning" --rpc.unsafe --keyring-backend test --home "$DATA_DIR" "$EXTRA_FLAGS" >"$DATA_DIR"/node.log"
./$CHAIND start --rpc.unsafe \
--json-rpc.enable true --api.enable \
--keyring-backend test --home $DATA_DIR --chain-id $CHAIN_ID $EXTRA_FLAGS
