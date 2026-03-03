#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"

CONTENT=$(curl -s "$URL")

# Extract first valid cookie from any channel
COOKIE_VALUE=$(echo "$CONTENT" | jq -r '
  .[] 
  | select(.cookie != null and .cookie != "") 
  | .cookie
' | head -n1)

# Stop if nothing found
if [ -z "$COOKIE_VALUE" ]; then
  echo "Error: No valid cookie found!"
  exit 1
fi

# Write JSON file
cat <<EOF > cookie.txt
{
  "cookieHeader": "$COOKIE_VALUE"
}
EOF

echo "Updated cookie JSON:"
echo "$COOKIE_VALUE"
