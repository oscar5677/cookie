#!/bin/bash

URL="https://raw.githubusercontent.com/alpha4528/m3u/refs/heads/main/jtv.m3u"

# Download file
CONTENT=$(curl -s "$URL")

# Extract first cookie JSON line
COOKIE_LINE=$(echo "$CONTENT" | grep -m 1 '"cookie"')

# Extract only cookie value
COOKIE_VALUE=$(echo "$COOKIE_LINE" | sed -E 's/.*"cookie":"([^"]+)".*/\1/')

# Save to cookie.txt
echo "$COOKIE_VALUE" > cookie.txt

echo "Updated cookie:"
echo "$COOKIE_VALUE"
