#!/bin/bash
# if chain not defined, defaults to evmos
if [[ -z "${CHAIN}" ]]; then CHAIN="evmos"; fi

# set denom based on chain
if [[ $CHAIN == "evmos" ]]; then DENOM="aevmos"; fi
if [[ $CHAIN == "ethermint" ]]; then DENOM="aphoton"; fi

KEY="dev0"
CHAINID="$CHAIN"_9000-1
CHAIND="$CHAIN"d
MONIKER="mymoniker"
DATA_DIR=$(mktemp -d -t evmos-datadir.XXXXX)
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"

GENESIS=$DATA_DIR/config/genesis.json
TEMP_GENESIS=$DATA_DIR/config/tmp_genesis.json
CONFIG=$DATA_DIR/config/config.toml
APP_CONFIG=$DATA_DIR/config/app.toml

echo "create and add new keys"
echo $MNEMONIC | ./$CHAIND keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --keyring-backend test --recover
echo "init Evmos with moniker=$MONIKER and chain-id=$CHAINID"
./$CHAIND init $MONIKER --chain-id $CHAINID --home $DATA_DIR
echo "prepare genesis: Allocate genesis accounts"
./$CHAIND add-genesis-account \
"$(./$CHAIND keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 100000000000000000000000000000000$DENOM \
--home $DATA_DIR --keyring-backend test

# Set gas limit in genesis
cat $GENESIS | jq '.consensus_params["block"]["max_gas"]="10000000"' > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

echo "- Set $DENOM as denom"
sed -i "s/aphoton/$DENOM/g" $GENESIS
sed -i "s/stake/$DENOM/g" $GENESIS

echo "prepare genesis: Sign genesis transaction"
./$CHAIND gentx $KEY 1000000000000000000$DENOM --keyring-backend test --home $DATA_DIR --keyring-backend test --chain-id $CHAINID
echo "prepare genesis: Collect genesis tx"
./$CHAIND collect-gentxs --home $DATA_DIR

echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./$CHAIND validate-genesis --home $DATA_DIR

sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
sed -i 's/enable-indexer = false/enable-indexer = true/g' $APP_CONFIG
perl -i -0pe 's/# Enable defines if the API server should be enabled.\nenable = false/# Enable defines if the API server should be enabled.\nenable = true/' $APP_CONFIG
# Change to 1s to have the same default configuration as v9
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$CONFIG"

# Change proposal periods to pass within a reasonable time for local testing
sed -i.bak 's/"max_deposit_period": "172800s"/"max_deposit_period": "30s"/g' "$GENESIS"
sed -i.bak 's/"voting_period": "172800s"/"voting_period": "30s"/g' "$GENESIS"

# Change max_subscription to for bots workers
sed -i.bak 's/max_subscriptions_per_client = 5/max_subscriptions_per_client = 500/g' "$CONFIG"

# set custom pruning settings
sed -i.bak 's/pruning = "default"/pruning = "custom"/g' "$APP_CONFIG"
sed -i.bak 's/pruning-keep-recent = "0"/pruning-keep-recent = "2"/g' "$APP_CONFIG"
sed -i.bak 's/pruning-interval = "0"/pruning-interval = "10"/g' "$APP_CONFIG"

# Make sure localhost is always 0.0.0.0 to make it work on docker network
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' $CONFIG
sed -i 's/127.0.0.1/0.0.0.0/g' $APP_CONFIG

echo "running evmos with extra flags $EXTRA_FLAGS"

echo "starting evmos node $i in background ..."
./$CHAIND start --pruning=nothing --rpc.unsafe \
--json-rpc.enable true --api.enable \
--keyring-backend test --home $DATA_DIR $EXTRA_FLAGS \
>$DATA_DIR/node.log
