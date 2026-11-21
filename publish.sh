#!/usr/bin/env bash
# Publish server.json to the official MCP Registry.
# Requires key.pem (the Ed25519 private key whose public half is the TXT record
# at the apex of cards4play.com) and mcp-publisher on PATH.
set -euo pipefail

DOMAIN="cards4play.com"
PRIVATE_KEY="$(openssl pkey -in key.pem -noout -text \
  | sed -n '/priv:/,/pub:/p' \
  | grep -v 'priv:\|pub:' \
  | tr -d ' :\n')"

if [ "${#PRIVATE_KEY}" -ne 64 ]; then
  echo "Unexpected private key length: ${#PRIVATE_KEY} (expected 64 hex chars)" >&2
  exit 1
fi

mcp-publisher login dns --domain "${DOMAIN}" --private-key "${PRIVATE_KEY}"
mcp-publisher publish
