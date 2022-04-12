#!/bin/sh
CONFIGDIR="/var/lib/ngrok"
ARGS=""

# Set the authorization token.
if [ -n "$NGROK_AUTHTOKEN" ]; then
    cat > $CONFIGDIR/auth-config.yml <<EOF
    version: 2
    authtoken: $NGROK_AUTHTOKEN
EOF
    ARGS="$ARGS --config=$CONFIGDIR/auth-config.yml"
fi

# Set the config file location; make sure agent uses default config even if NGROK_AUTHTOKEN is set
if [ -n "$NGROK_CONFIG" ]; then
    ARGS="$ARGS --config=$NGROK_CONFIG"
else
    ARGS="--config=$CONFIGDIR/ngrok.yml $ARGS"
fi

if [ $# -eq 0 ]; then
    ARGS="start $ARGS --all"
fi

exec ngrok "$@" $ARGS
