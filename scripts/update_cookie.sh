#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"

CONTENT=$(curl -s "$URL")

# Extract first valid cookie
COOKIE_VALUE=$(echo "$CONTENT" | jq -r '
  .[]
  | select(.cookie != null and .cookie != "")
  | .cookie
' | head -n1)

# If no cookie found → keep old one silently
if [ -z "$COOKIE_VALUE" ]; then
  echo "No valid cookie found. Keeping previous cookie."
  exit 0
fi

# Read old cookie
OLD_COOKIE=$(jq -r '.cookieHeader' cookie.txt 2>/dev/null)

# If same → skip update
if [ "$OLD_COOKIE" = "$COOKIE_VALUE" ]; then
  echo "Cookie unchanged. Skipping update."
  exit 0
fi

echo "Cookie changed. Updating file..."

cat <<EOF > cookie.txt
{
  "cookieHeader": "$COOKIE_VALUE"
}
EOF

echo "Updated cookie JSON:"
echo "$COOKIE_VALUE"
