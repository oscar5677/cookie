#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"

CONTENT=$(curl -s "$URL")

# Extract unique cookies
mapfile -t COOKIES < <(echo "$CONTENT" | jq -r '
  [.[] | select(.cookie != null and .cookie != "") | .cookie] | unique[]
')

if [ ${#COOKIES[@]} -eq 0 ]; then
  echo "No valid cookies found."
  exit 0
fi

# Build JSON in memory
NEW_JSON="{"

for i in "${!COOKIES[@]}"; do
  INDEX=$((i+1))

  if [ $INDEX -eq 1 ]; then
    KEY="cookieHeader"
  else
    KEY="cookieHeader$INDEX"
  fi

  VALUE="${COOKIES[$i]}"

  if [ $INDEX -eq ${#COOKIES[@]} ]; then
    NEW_JSON="$NEW_JSON\"$KEY\":\"$VALUE\""
  else
    NEW_JSON="$NEW_JSON\"$KEY\":\"$VALUE\","
  fi
done

NEW_JSON="$NEW_JSON}"

# Compare with existing file
if [ -f cookie.txt ] && [ "$(cat cookie.txt)" = "$NEW_JSON" ]; then
  echo "Cookies unchanged. Skipping update."
  exit 0
fi

echo "$NEW_JSON" > cookie.txt
echo "Cookie file updated."
