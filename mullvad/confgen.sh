#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2016-2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

die() {
	echo "[-] Error: $1" >&2
	exit 1
}

PROGRAM="${0##*/}"
ARGS=( "$@" )
SELF="${BASH_SOURCE[0]}"
[[ $SELF == */* ]] || SELF="./$SELF"
SELF="$(cd "${SELF%/*}" && pwd -P)/${SELF##*/}"
DATADIR="$(pwd)/wgconf"
mkdir -p "$DATADIR"
[[ $UID == 0 ]] || exec sudo -p "[?] $PROGRAM must be run as root. Please enter the password for %u to continue: " -- "$BASH" -- "$SELF" "${ARGS[@]}"

[[ ${BASH_VERSINFO[0]} -ge 4 ]] || die "bash ${BASH_VERSINFO[0]} detected, when bash 4+ required"

type curl >/dev/null || die "Please install curl and then try again."
type jq >/dev/null || die "Please install jq and then try again."
set -e

echo "[+] Contacting Mullvad API for server locations."
declare -A SERVER_ENDPOINTS
declare -A SERVER_PUBLIC_KEYS
declare -A SERVER_LOCATIONS
declare -a SERVER_CODES

RESPONSE="$(curl -LsS https://api.mullvad.net/public/relays/wireguard/v1/)" || die "Unable to connect to Mullvad API."
FIELDS="$(jq -r 'foreach .countries[] as $country (.; .; foreach $country.cities[] as $city (.; .; foreach $city.relays[] as $relay (.; .; $country.name, $city.name, $relay.hostname, $relay.public_key, $relay.ipv4_addr_in)))' <<<"$RESPONSE")" || die "Unable to parse response."
while read -r COUNTRY && read -r CITY && read -r HOSTNAME && read -r PUBKEY && read -r IPADDR; do
	CODE="${HOSTNAME%-wireguard}"
	SERVER_CODES+=( "$CODE" )
	SERVER_LOCATIONS["$CODE"]="$CITY, $COUNTRY"
	SERVER_PUBLIC_KEYS["$CODE"]="$PUBKEY"
	SERVER_ENDPOINTS["$CODE"]="$IPADDR:51820"
done <<<"$FIELDS"

shopt -s nocasematch
for CODE in "${SERVER_CODES[@]}"; do
	CONFIGURATION_FILE="$DATADIR/mullvad-$CODE.conf"
	[[ -f $CONFIGURATION_FILE ]] || continue
done
shopt -u nocasematch

# parse the config we bought
FULL_CONFIG="$(cat "$DATADIR"/wg_params)"
PRIVATE_KEY="$(echo "$FULL_CONFIG" | awk -F';' '{print $1}')"
ADDRESS="$(echo "$FULL_CONFIG" | awk -F';' '{print $2}')"
DNS="$(echo "$FULL_CONFIG" | awk -F';' '{print $3}')"

echo "[+] Writing WriteGuard configuration files."
for CODE in "${SERVER_CODES[@]}"; do
	LOCATION=${SERVER_LOCATIONS["$CODE"]}
	SUFFIX=""

	if [[ "$(echo "$LOCATION" | awk -F', ' '{print $3}')" == "USA" ]]; then
		SUFFIX+="$(echo "$LOCATION" | awk -F', ' '{print $3"-"$2"-"$1}' | sed 's/ /_/g')"
	else
		SUFFIX+="$(echo "$LOCATION" | awk -F', ' '{print $2"-"$1}' | sed 's/ /_/g')"
	fi
	SUFFIX+="-$CODE"

	CONFIGURATION_FILE="$DATADIR/$SUFFIX.conf"
	umask 077
	rm -f "$CONFIGURATION_FILE.tmp"
	cat > "$CONFIGURATION_FILE.tmp" <<-_EOF
		[Interface]
		PrivateKey = $PRIVATE_KEY
		Address = $ADDRESS
		DNS = $DNS

		[Peer]
		PublicKey = ${SERVER_PUBLIC_KEYS["$CODE"]}
		Endpoint = ${SERVER_ENDPOINTS["$CODE"]}
		AllowedIPs = 0.0.0.0/0, ::/0
	_EOF
	mv "$CONFIGURATION_FILE.tmp" "$CONFIGURATION_FILE"
done

# drop perms for friendlier use
find ./wgconf/ -type f -name "*.conf" -exec chmod 0644 {} \;

echo "[+] Success."

echo "Please wait up to 60 seconds for your public key to be added to the servers."
