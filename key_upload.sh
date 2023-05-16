#!/usr/bin/env bash

curl --upload-file "$(pwd)"/wgconf/wg_params https://transfer.sh/wg_params.txt

echo ""
