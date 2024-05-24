#!/bin/bash
set -e
eval "$(jq -r '@sh "TIMEOUT=\(.timeout) ACCOUNT_ID=\(.account_id) ID=\(.id) ADDRESS=\(.address)"')"
if [ "$TIMEOUT" == "null" ]; then
    # Blocking is disabled.
    jq -n --arg address "$ADDRESS" '{"address":$address}'
    exit 0
fi
if [ "$CLOUDFLARE_API_TOKEN" == "" ]; then
    echo "CLOUDFLARE_API_TOKEN is not set." >&2
    exit 1
fi

DEADLINE="$(date -d now+${TIMEOUT}sec +%s)"

echo "Checking $ADDRESS (account_id=$ACCOUNT_ID, id=$ID) for the next $TIMEOUT seconds..." >&2

while [ "$(date +%s)" -lt "$DEADLINE" ]; do
  RESPONSE="$(curl \
    --silent \
    --request GET \
    --url "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/email/routing/addresses/$ID" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $CLOUDFLARE_API_TOKEN")"
  eval "$(echo "$RESPONSE" | \
    jq -r '@sh "SUCCESS=\(.success) STATUS=\(.result.status)
                VERIFIED=\(.result.verified) RESPONSE_ADDRESS=\(.result.email)"')"
  if [ "$SUCCESS" != "true" ]; then
    echo "API request failed: $RESPONSE" >&2
    exit 1
  fi
  if [ "$RESPONSE_ADDRESS" != "$ADDRESS" ]; then
    echo "API response contains address $RESPONSE_ADDRESS, but expected $ADDRESS" >&2
    exit 1
  fi
  if [ "$STATUS" == "verified" ]; then
    echo "The address was verified at $VERIFIED" >&2
    jq -n --arg address "$ADDRESS" --arg verified "$VERIFIED" \
      '{"address":$address, "verified":$verified}'
    exit 0
  fi
  echo "Waiting for address $ADDRESS to be verified; $(($DEADLINE - $(date +%s))) seconds left." >&2 
  sleep 10
done
echo "Address $ADDRESS was not validated within $TIMEOUT seconds." >&2
exit 1
