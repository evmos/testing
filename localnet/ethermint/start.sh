#!/bin/bash

KEY="dev0"
CHAINID="ethermint_9000-1"
MONIKER="mymoniker"
DATA_DIR=$(mktemp -d -t ethermint-datadir.XXXXX)
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"

GENESIS=$DATA_DIR/config/genesis.json
TEMP_GENESIS=$DATA_DIR/config/tmp_genesis.json
CONFIG=$DATA_DIR/config/config.toml

echo "create and add new keys"
echo $MNEMONIC | ./ethermintd keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --keyring-backend test --recover
echo "init Ethermint with moniker=$MONIKER and chain-id=$CHAINID"
./ethermintd init $MONIKER --chain-id $CHAINID --home $DATA_DIR
echo "prepare genesis: Allocate genesis accounts"
./ethermintd add-genesis-account \
"$(./ethermintd keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 100000000000000000000000000000000aphoton,1000000000000000000stake \
--home $DATA_DIR --keyring-backend test

# Set gas limit in genesis
cat $GENESIS | jq '.consensus_params["block"]["max_gas"]="10000000"' > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

echo "prepare genesis: Sign genesis transaction"
./ethermintd gentx $KEY 1000000000000000000stake --keyring-backend test --home $DATA_DIR --keyring-backend test --chain-id $CHAINID
echo "prepare genesis: Collect genesis tx"
./ethermintd collect-gentxs --home $DATA_DIR
sed -i 's/aphoton/g' $GENESIS

echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./ethermintd validate-genesis --home $DATA_DIR

sed -i 's/prometheus = false/prometheus = true/g' $CONFIG
sed -i 's/pprof_laddr = "localhost:6060"/pprof_laddr = "0.0.0.0:6060"/g' $CONFIG
# Change to 1s to have the same default configuration as v9
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' "$CONFIG"


echo "running ethermint with extra flags $EXTRA_FLAGS"

echo "starting ethermint node $i in background ..."
./ethermintd start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log $EXTRA_FLAGS
