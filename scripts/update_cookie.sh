#!/bin/bash

# ----------- SOURCE URLS -----------
URL="https://pkll.xojiv79335.workers.dev/"
M3U_URL="https://j1.uhd2026.workers.dev/"

# ----------- FETCH JSON API -----------
CONTENT=$(curl -s --max-time 10 "$URL")

# Validate JSON
if ! echo "$CONTENT" | jq . >/dev/null 2>&1; then
  echo "Invalid JSON from API. Skipping..."
  exit 0
fi

# Extract unique cookies (preserve order)
mapfile -t COOKIES < <(echo "$CONTENT" | jq -r '
  [.[] | select(.cookie != null and .cookie != "") | .cookie]
  | reduce .[] as $c ([]; if index($c) then . else . + [$c] end)
  | .[]
')

if [ ${#COOKIES[@]} -eq 0 ]; then
  echo "No valid JSON cookies found. Skipping..."
  exit 0
fi

# ----------- FETCH M3U PLAYLIST -----------
M3U_CONTENT=$(curl -s --max-time 10 "$M3U_URL")

# Extract cookies from #EXTHTTP lines
mapfile -t JTV_COOKIES < <(echo "$M3U_CONTENT" | grep -oP '#EXTHTTP:\{"cookie":"\K[^"]+')

# Remove duplicates (preserve order)
UNIQUE_JTV=()
for c in "${JTV_COOKIES[@]}"; do
  [[ " ${UNIQUE_JTV[*]} " =~ " $c " ]] || UNIQUE_JTV+=("$c")
done
JTV_COOKIES=("${UNIQUE_JTV[@]}")

# ----------- DEFAULT COOKIES -----------
DEFAULT_COOKIES=(
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
  "__hdnea__=st=1774003153~exp=1774089553~acl=/*~hmac=70dc37139d185e91fa6b7753aa0a40e814e17cc2235346a6ae078ddb6d000a06"
)

# ----------- BUILD JSON SAFELY -----------
NEW_JSON="{"

add_entry() {
  KEY="$1"
  VALUE="$2"

  if [ "$NEW_JSON" != "{" ]; then
    NEW_JSON="$NEW_JSON,"
  fi

  NEW_JSON="$NEW_JSON\"$KEY\":\"$VALUE\""
}

# Add default cookies
for i in "${!DEFAULT_COOKIES[@]}"; do
  add_entry "cookieDefault$((i+1))" "${DEFAULT_COOKIES[$i]}"
done

# Add JSON API cookies
for i in "${!COOKIES[@]}"; do
  if [ $i -eq 0 ]; then
    add_entry "cookieHeader" "${COOKIES[$i]}"
  else
    add_entry "cookieHeader$((i+1))" "${COOKIES[$i]}"
  fi
done

# Add M3U cookies
for i in "${!JTV_COOKIES[@]}"; do
  if [ $i -eq 0 ]; then
    add_entry "cookieHeaderjtv" "${JTV_COOKIES[$i]}"
  else
    add_entry "cookieHeaderjtv$((i+1))" "${JTV_COOKIES[$i]}"
  fi
done

NEW_JSON="$NEW_JSON}"

# ----------- DEBUG INFO -----------
echo "Default cookies: ${#DEFAULT_COOKIES[@]}"
echo "JSON cookies: ${#COOKIES[@]}"
echo "JTV cookies: ${#JTV_COOKIES[@]}"

# ----------- COMPARE & SAVE -----------
if [ -f cookie.txt ] && [ "$(cat cookie.txt)" = "$NEW_JSON" ]; then
  echo "Cookies unchanged. Skipping update."
  exit 0
fi

echo "$NEW_JSON" > cookie.txt
echo "Cookie file updated."
