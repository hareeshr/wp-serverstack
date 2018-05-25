#!/usr/bin/env bash
lexicon route53 \
--auth-access-key=route53_access_key --auth-access-secret=route53_access_secret \
"$1" "${CERTBOT_DOMAIN}" TXT \
--name "_acme-challenge.${CERTBOT_DOMAIN}" \
--content "${CERTBOT_VALIDATION}" || exit 255

if [ "$1" == "create" ] && [[ "$CERTBOT_DOMAIN" = 'www'* ]]; then
  sleep 30
fi
