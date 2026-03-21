#!/bin/bash

URL="https://pkll.xojiv79335.workers.dev/"
M3U_URL="https://j1.uhd2026.workers.dev/"

# ----------- LOAD EXISTING COOKIES -----------
OLD_JSON=""
if [ -f cookie.txt ]; then
  OLD_JSON=$(cat cookie.txt)
fi

# Extract old JSON cookies
mapfile -t OLD_COOKIES < <(echo "$OLD_JSON" | jq -r '
  to_entries[]
  | select(.key | startswith("cookieHeader") and (.key | startswith("cookieHeaderjtv") | not))
  | .value
' 2>/dev/null)

# Extract old JTV cookies
mapfile -t OLD_JTV_COOKIES < <(echo "$OLD_JSON" | jq -r '
  to_entries[]
  | select(.key | startswith("cookieHeaderjtv"))
  | .value
' 2>/dev/null)

# ----------- FETCH JSON API -----------
CONTENT=$(curl -s --max-time 10 "$URL")

NEW_JSON_COOKIES=()

if echo "$CONTENT" | jq . >/dev/null 2>&1; then
  mapfile -t NEW_JSON_COOKIES < <(echo "$CONTENT" | jq -r '
    [.[] | select(.cookie != null and .cookie != "") | .cookie]
    | reduce .[] as $c ([]; if index($c) then . else . + [$c] end)
    | .[]
  ')
fi

# Fallback if failed
if [ ${#NEW_JSON_COOKIES[@]} -eq 0 ]; then
  echo "JSON source failed → using old cookies"
  COOKIES=("${OLD_COOKIES[@]}")
else
  COOKIES=("${NEW_JSON_COOKIES[@]}")
fi

# ----------- FETCH M3U -----------
M3U_CONTENT=$(curl -s --max-time 10 "$M3U_URL")

NEW_JTV_COOKIES=()
mapfile -t NEW_JTV_COOKIES < <(echo "$M3U_CONTENT" | grep -oP '#EXTHTTP:\{"cookie":"\K[^"]+')

# Deduplicate
UNIQUE_JTV=()
for c in "${NEW_JTV_COOKIES[@]}"; do
  [[ " ${UNIQUE_JTV[*]} " =~ " $c " ]] || UNIQUE_JTV+=("$c")
done
NEW_JTV_COOKIES=("${UNIQUE_JTV[@]}")

# Fallback if failed
if [ ${#NEW_JTV_COOKIES[@]} -eq 0 ]; then
  echo "JTV source failed → using old cookies"
  JTV_COOKIES=("${OLD_JTV_COOKIES[@]}")
else
  JTV_COOKIES=("${NEW_JTV_COOKIES[@]}")
fi

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

# Defaults
for i in "${!DEFAULT_COOKIES[@]}"; do
  add_entry "cookieDefault$((i+1))" "${DEFAULT_COOKIES[$i]}"
done

# JSON cookies
for i in "${!COOKIES[@]}"; do
  if [ $i -eq 0 ]; then
    add_entry "cookieHeader" "${COOKIES[$i]}"
  else
    add_entry "cookieHeader$((i+1))" "${COOKIES[$i]}"
  fi
done

# JTV cookies
for i in "${!JTV_COOKIES[@]}"; do
  if [ $i -eq 0 ]; then
    add_entry "cookieHeaderjtv" "${JTV_COOKIES[$i]}"
  else
    add_entry "cookieHeaderjtv$((i+1))" "${JTV_COOKIES[$i]}"
  fi
done

NEW_JSON="$NEW_JSON}"

# ----------- DEBUG -----------
echo "Final JSON cookies: ${#COOKIES[@]}"
echo "Final JTV cookies: ${#JTV_COOKIES[@]}"

# ----------- COMPARE & SAVE -----------
if [ -f cookie.txt ] && [ "$(cat cookie.txt)" = "$NEW_JSON" ]; then
  echo "Cookies unchanged. Skipping update."
  exit 0
fi

echo "$NEW_JSON" > cookie.txt
echo "Cookie file updated."
