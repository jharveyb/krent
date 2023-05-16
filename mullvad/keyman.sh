#!/usr/bin/env bash
DATADIR="$(pwd)/wgconf"

# TODO: Check for mullvad CLI tool
# TODO: Pull account number from env

ACCOUNT="$YOUR_ACCOUNT_NUMBER_HERE"

register() {
    mullvad account set "$ACCOUNT"
}

new_key() {
    "$(pwd)"/mullvad/keygen_stub.sh
}

gen_config() {
    PRIVATE_KEY="$(cat "$DATADIR"/privkey)"
    echo "[+] Contacting Mullvad API."
    RESPONSE="$(curl -sSL https://api.mullvad.net/wg/ -d account="$ACCOUNT" --data-urlencode pubkey="$(wg pubkey <<<"$PRIVATE_KEY")")" || die "Could not talk to Mullvad API."
    [[ $RESPONSE =~ ^[0-9a-f:/.,]+$ ]] || die "$RESPONSE"
    ADDRESS="$RESPONSE"
    DNS="193.138.218.74"
    echo "$ADDRESS"
    echo "$ADDRESS" > "$DATADIR/addr"
    echo "$DNS" > "$DATADIR/dns"
    FULL_CONFIG=""
    FULL_CONFIG+="$PRIVATE_KEY"
    FULL_CONFIG+=";"
    FULL_CONFIG+="$ADDRESS"
    FULL_CONFIG+=";"
    FULL_CONFIG+="$DNS"
    echo "$FULL_CONFIG" > "$DATADIR"/wg_params
}

parse_config() {
    FULL_CONFIG="$(cat "$DATADIR"/full_config)"
    PRIVATE_KEY="$(echo "$FULL_CONFIG" | awk -F';' '{print $1}')"
    ADDRESS="$(echo "$FULL_CONFIG" | awk -F';' '{print $2}')"
    DNS="$(echo "$FULL_CONFIG" | awk -F';' '{print $3}')"
}

remove_key() {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR"
    echo "[+] Clearing private key."
    mullvad tunnel wireguard key regenerate
}

register
new_key
gen_config
# remove_key
