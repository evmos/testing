#!/bin/bash

KEY="dev0"
CHAINID="evmos_9000-1"
MONIKER="mymoniker"
DATA_DIR=$(mktemp -d -t evmos-datadir.XXXXX)
MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"

echo "create and add new keys"
echo $MNEMONIC | ./evmosd keys add $KEY --home $DATA_DIR --no-backup --chain-id $CHAINID --keyring-backend test --recover
echo "init Evmos with moniker=$MONIKER and chain-id=$CHAINID"
./evmosd init $MONIKER --chain-id $CHAINID --home $DATA_DIR
echo "prepare genesis: Allocate genesis accounts"
./evmosd add-genesis-account \
"$(./evmosd keys show $KEY -a --home $DATA_DIR --keyring-backend test)" 100000000000000000000000000000000aevmos,1000000000000000000stake \
--home $DATA_DIR --keyring-backend test
echo "prepare genesis: Sign genesis transaction"
./evmosd gentx $KEY 1000000000000000000stake --keyring-backend test --home $DATA_DIR --keyring-backend test --chain-id $CHAINID
echo "prepare genesis: Collect genesis tx"
./evmosd collect-gentxs --home $DATA_DIR
sed -i 's/aphoton/aevmos/g' $DATA_DIR/config/genesis.json

echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./evmosd validate-genesis --home $DATA_DIR

sed -i 's/prometheus = false/prometheus = true/g' $DATA_DIR/config/config.toml

echo "running evmos with extra flags $EXTRA_FLAGS"

echo "starting evmos node $i in background ..."
./evmosd start --pruning=nothing --rpc.unsafe \
--keyring-backend test --home $DATA_DIR \
>$DATA_DIR/node.log $EXTRA_FLAGS  &>> /opt/evmosd.log & disown

echo "started evmos node"
tail -f /dev/null

# curl localhost:8545 -X POST -H "Content-Type: application/json" --data '{"method":"eth_getBalance","params":["0x1cF80B60F4F58221AaFFDBb2e513C0Ef1F809494", "latest"],"id":1,"jsonrpc":"2.0"}'
