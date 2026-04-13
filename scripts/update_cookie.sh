#!/bin/bash

#URL="https://pkll.xojiv79335.workers.dev/"

#URL="https://my-api-5e7.pages.dev/jiotv2.json"

URL="https://allrounder-live4.pages.dev/api/cookie.json"

CONTENT=$(curl -s "$URL")

# Extract unique cookies while preserving original order
mapfile -t COOKIES < <(echo "$CONTENT" | jq -r '
  if type=="array" then
    [.[] | select(.cookie != null and .cookie != "") | .cookie]
  else
    [select(.cookie != null and .cookie != "") | .cookie]
  end
  | reduce .[] as $c ([]; if index($c) then . else . + [$c] end)
  | .[]
')

if [ ${#COOKIES[@]} -eq 0 ]; then
  echo "No valid cookies found."
  exit 0
fi
# ---- DEFAULT COOKIES (STATIC) ----
DEFAULT_COOKIES=(
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
)


# Build JSON in memory
# Build JSON in memory
NEW_JSON="{"

TOTAL_DEFAULTS=${#DEFAULT_COOKIES[@]}
TOTAL_DYNAMIC=${#COOKIES[@]}

# Add default cookies first
for i in "${!DEFAULT_COOKIES[@]}"; do
  KEY="cookieDefault$((i+1))"
  VALUE="${DEFAULT_COOKIES[$i]}"

  NEW_JSON="$NEW_JSON\"$KEY\":\"$VALUE\","
done

# Add dynamic cookies
for i in "${!COOKIES[@]}"; do
  INDEX=$((i+1))

  if [ $INDEX -eq 1 ]; then
    KEY="cookieHeader"
  else
    KEY="cookieHeader$INDEX"
  fi

  VALUE="${COOKIES[$i]}"

  # Check if last element overall
  if [ $i -eq $((TOTAL_DYNAMIC - 1)) ]; then
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

#echo "$NEW_JSON" > cookie.txt
if [ -f cookie.txt ]; then
  MERGED=$(jq -s '.[0] * .[1]' cookie.txt <(echo "$NEW_JSON"))
  echo "$MERGED" > cookie.txt
else
  echo "$NEW_JSON" > cookie.txt
fi

echo "Cookie file updated."
