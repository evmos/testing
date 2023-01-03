#!/bin/bash

CHAINID="evmos_9999-1"
MONIKER="orchestrator"

# Orchestrator account
KEY="orchestrator"
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"

BUILD_DIR=$(pwd)/localnet/build
DATA_DIR=$BUILD_DIR/node4/evmosd
GENESIS=$DATA_DIR/config/genesis.json
TEMP_GENESIS=$DATA_DIR/config/tmp_genesis.json
CONFIG=$DATA_DIR/config/config.toml

# create necessary directory for orchestrator node
mkdir -r $DATA_DIR

echo "create and add new keys"
echo $MNEMONIC | evmosd keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --keyring-backend test --recover
echo "init Evmos with moniker=$MONIKER and chain-id=$CHAINID"
evmosd init $MONIKER --chain-id $CHAINID --home $DATA_DIR

echo "Prepare genesis..."
echo "- Set gas limit in genesis"
cat $GENESIS | jq '.consensus_params["block"]["max_gas"]="10000000"' > $TEMP_GENESIS && mv $TEMP_GENESIS $GENESIS

echo "- Set aevmos as denom"
sed -i 's/aphoton/aevmos/g' $GENESIS
sed -i 's/stake/aevmos/g' $GENESIS

echo "- Allocate genesis accounts"
evmosd add-genesis-account \
"$(evmosd keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 100000000000000000000000000000000aevmos \
--home $DATA_DIR --keyring-backend test

echo "- Sign genesis transaction"
evmosd gentx $KEY 1000000000000000000aevmos --keyring-backend test --home $DATA_DIR --chain-id $CHAINID

echo "- Add all other validators genesis accounts"
for i in $(find $BUILD_DIR/gentxs -name "*.json");do
    address=$(cat "$i" | jq '.body.messages[0].delegator_address'|tr -d '"')
    evmosd add-genesis-account  "$address" 100000000000000000000000000aevmos --home $DATA_DIR --keyring-backend test
    [ $? -eq 0 ] && echo "$address added" || echo "$address failed"
done

# add gentx to gentxs dir
cp $DATA_DIR/config/gentx/*.json $BUILD_DIR/gentxs/node4.json

echo "- Collect genesis tx"
evmosd collect-gentxs --home $DATA_DIR

echo "- Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
evmosd validate-genesis --home $DATA_DIR

echo "- Distribute final genesis.json to all validators"
for i in $(ls $BUILD_DIR | grep 'node');do
    cp $GENESIS $BUILD_DIR/$i/evmosd/config/genesis.json
    [ $? -eq 0 ] && echo "$i: genesis updated successfully" || echo "$i: genesis update failed"
done

echo "copy config.toml to get the seeds"
cp $BUILD_DIR/node0/evmosd/config/config.toml $CONFIG
sed -i 's/moniker = \"node1\"/moniker = \"orchestrator\"/g' $CONFIG
