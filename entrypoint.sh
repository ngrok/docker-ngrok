#!/bin/sh -e
ARGS=""

# Set the authorization token.
if [ -n "$NGROK_AUTHTOKEN" ]; then
  cat > /var/lib/ngrok/auth-config.yml <<EOF
  authtoken: $NGROK_AUTHTOKEN
EOF
  ARGS="$ARGS --config=/var/lib/ngrok/auth-config.yml"
fi

# Set the config file location; make sure agent uses default config even if NGROK_AUTHTOKEN is set
if [ -n "$NGROK_CONFIG" ]; then
  ARGS="$ARGS --config=$NGROK_CONFIG"
else
  ARGS="--config=/var/lib/ngrok/ngrok.yml $ARGS"
fi

exec "/bin/ngrok" "$@" $ARGS
