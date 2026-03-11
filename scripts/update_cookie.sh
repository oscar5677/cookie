#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"

CONTENT=$(curl -s "$URL")

# Extract unique cookies
mapfile -t COOKIES < <(echo "$CONTENT" | jq -r '
  [.[] | select(.cookie != null and .cookie != "") | .cookie] | unique[]
')

# If none found
if [ ${#COOKIES[@]} -eq 0 ]; then
  echo "No valid cookies found."
  exit 0
fi

# Generate JSON
echo "{" > cookie.txt

for i in "${!COOKIES[@]}"; do
  INDEX=$((i+1))

  if [ $INDEX -eq 1 ]; then
    KEY="cookieHeader"
  else
    KEY="cookieHeader$INDEX"
  fi

  VALUE="${COOKIES[$i]}"

  if [ $INDEX -eq ${#COOKIES[@]} ]; then
    echo "  \"$KEY\": \"$VALUE\"" >> cookie.txt
  else
    echo "  \"$KEY\": \"$VALUE\"," >> cookie.txt
  fi
done

echo "}" >> cookie.txt

echo "Updated cookie JSON with ${#COOKIES[@]} unique cookies."
