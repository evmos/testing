#!/bin/bash

# NODE_IP=192.167.10.2
# PORT=26657

# echo "Waiting node to launch on $PORT..."
# while ! timeout 1 bash -c "echo > /dev/tcp/$NODE_IP/$PORT"; do   
#   sleep 1
# done

# Orchestrator account
# KEY="orchestrator"
# MNEMONIC="stumble tilt business detect father ticket major inner awake jeans name vibrant tribe pause crunch sad wine muscle hidden pumpkin inject segment rocket silver"
ORCHESTRATOR_ADDR=evmos1rnuqkc857kpzr2hlmwew2y7qau0cp9y5e3gng4

DATA_DIR=/evmos
GENESIS=$DATA_DIR/config/genesis.json

# echo "create and add orchestrator keys"
# echo $MNEMONIC | ./evmosd keys add $KEY --home $DATA_DIR --no-backup --keyring-backend test --recover

CHAINID=$(grep -oP '\"evmos_.*?\"' $GENESIS)
echo "chain id: $CHAINID"
VALIDATOR_KEY=$(./evmosd keys list --keyring-backend test --home $DATA_DIR | grep -oP 'node.*')
echo "validator key: $VALIDATOR_KEY"

echo "fund orchestrator account"
echo "./evmosd tx bank send $VALIDATOR_KEY $ORCHESTRATOR_ADDR 10000000000000000000aevmos --home $DATA_DIR --keyring-backend test --chain-id $CHAINID -y" 
./evmosd tx bank send $VALIDATOR_KEY $ORCHESTRATOR_ADDR 10000000000000000000aevmos --home $DATA_DIR --keyring-backend test --chain-id $CHAINID -y
