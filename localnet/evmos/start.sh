#!/bin/bash

# Orchestrator account
KEY="orchestrator"
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"
ORCHESTRATOR_ADDR=evmos1rnuqkc857kpzr2hlmwew2y7qau0cp9y5e3gng4

DATA_DIR=/evmos
GENESIS=$DATA_DIR/config/genesis.json
TEMP_GENESIS=$DATA_DIR/config/tmp_genesis.json
CONFIG=$DATA_DIR/config/config.toml

# echo "create and add orchestrator keys"
# echo $MNEMONIC | ./evmosd keys add $KEY --home $DATA_DIR --no-backup --keyring-backend test --recover
# echo "init Evmos with moniker=$MONIKER and chain-id=$CHAINID"
# ./evmosd init $MONIKER --chain-id $CHAINID --home $DATA_DIR
# echo "prepare genesis: Allocate genesis accounts"
# ./evmosd add-genesis-account \
# "$(./evmosd keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 100000000000000000000000000000000aevmos \
# --home $DATA_DIR --keyring-backend test

# Set gas limit in genesis
cat $GENESIS | jq '.consensus_params["block"]["max_gas"]="10000000"' > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

# echo "prepare genesis: Sign genesis transaction"
# ./evmosd gentx $KEY 1000000000000000000aevmos --keyring-backend test --home $DATA_DIR --keyring-backend test
# echo "prepare genesis: Collect genesis tx"
# ./evmosd collect-gentxs --home $DATA_DIR
sed -i 's/aphoton/aevmos/g' $GENESIS

echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./evmosd validate-genesis --home $DATA_DIR

sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' $CONFIG
# Change to 1s to have the same default configuration as v9
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$CONFIG"

echo "running evmos with extra flags $EXTRA_FLAGS"
echo "starting evmos node $i in background ..."
./evmosd start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log $EXTRA_FLAGS
