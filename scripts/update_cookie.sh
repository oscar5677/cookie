#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"

CONTENT=$(curl -s "$URL")

# Extract first valid cookie
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

# 🔎 Read old cookie (if file exists)
OLD_COOKIE=$(jq -r '.cookieHeader' cookie.txt 2>/dev/null)

# 🔄 Compare
if [ "$OLD_COOKIE" = "$COOKIE_VALUE" ]; then
  echo "Cookie unchanged. Skipping update."
  exit 0
fi

echo "Cookie changed. Updating file..."

# ✍️ Write new cookie
cat <<EOF > cookie.txt
{
  "cookieHeader": "$COOKIE_VALUE"
}
EOF

echo "Updated cookie JSON:"
echo "$COOKIE_VALUE"
