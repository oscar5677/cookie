#!/bin/bash

URL="https://raw.githubusercontent.com/alpha4528/m3u/refs/heads/main/jtv.m3u"

# Download file
CONTENT=$(curl -s "$URL")

# Extract first EXTHTTP cookie line
COOKIE_LINE=$(echo "$CONTENT" | grep -m 1 '^#EXTHTTP:.*"cookie"')

# Extract only cookie value
COOKIE_VALUE=$(echo "$COOKIE_LINE" | sed -E 's/.*"cookie":"([^"]+)".*/\1/')

# Create JSON format
JSON_OUTPUT=$(cat <<EOF
{
  "cookieHeader": "$COOKIE_VALUE"
}
EOF
)

# Save to cookie.txt
echo "$JSON_OUTPUT" > cookie.txt

echo "Updated cookie JSON:"
echo "$JSON_OUTPUT"
