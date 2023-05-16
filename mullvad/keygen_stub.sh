#!/usr/bin/env bash
DATADIR="$(pwd)/wgconf"

# NEED SUDO

rm -rf "$DATADIR"
mkdir -p "$DATADIR"
echo "[+] Generating new private key."
mullvad tunnel wireguard key regenerate
PRIVKEY=$(jq '.[0].wireguard.private_key' < /etc/mullvad-vpn/account-history.json)
echo "$PRIVKEY" | sed s/\"//g > "$DATADIR/privkey"
