#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"

CONTENT=$(curl -s "$URL")

# Extract first channel_url using jq
CHANNEL_URL=$(echo "$CONTENT" | jq -r '.[0].channel_url')

# Extract __hdnea__
COOKIE_VALUE=$(echo "$CHANNEL_URL" | grep -o '__hdnea__=.*')

if [ -z "$COOKIE_VALUE" ]; then
  echo "Error: No __hdnea__ token found!"
  exit 1
fi

cat <<EOF > cookie.txt
{
  "cookieHeader": "$COOKIE_VALUE"
}
EOF

echo "Updated cookie JSON:"
echo "$COOKIE_VALUE"
