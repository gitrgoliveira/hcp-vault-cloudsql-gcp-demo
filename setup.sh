#!/bin/bash
echo "******************************************************************"
echo "* Script to setup challenge                                      *"
echo "******************************************************************"
echo
echo
echo "Please enter your HCP Vault address."
read VAULT_ADDR
echo
echo "Please enter your HCP Vault admin token (no output)."
read -s VAULT_TOKEN
echo
echo "HCP Vault hostname : $VAULT_ADDR"
# echo "HCP Vault token : $VAULT_TOKEN"
echo
read -p "Do these look right to you? Y/n " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  echo "Please try again."
  exit 1
fi
echo

cat >> credentials.env <<EOM
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_TOKEN
EOM
source credentials.env

cat >> terraform.tfvars <<EOM
vault_address = "$VAULT_ADDR"
EOM
exit 0
