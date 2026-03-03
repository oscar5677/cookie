#!/bin/bash

URL="https://raw.githubusercontent.com/alpha4528/m3u/refs/heads/main/jtv.m3u"

# Download file
CONTENT=$(curl -s "$URL")

# Extract first EXTHTTP cookie line
COOKIE_LINE=$(echo "$CONTENT" | grep -m 1 '^#EXTHTTP:.*"cookie"')

# Extract only cookie value
COOKIE_VALUE=$(echo "$COOKIE_LINE" | sed -E 's/.*"cookie":"([^"]+)".*/\1/')

# If cookie not found, stop workflow
if [ -z "$COOKIE_VALUE" ]; then
  echo "Error: No cookie found!"
  exit 1
fi

# Create JSON directly into file
cat <<EOF > cookie.txt
{
  "cookieHeader": "$COOKIE_VALUE"
}
EOF

echo "Updated cookie JSON:"
echo "$COOKIE_VALUE"
