#!/bin/sh
CONFIGDIR="/var/lib/ngrok"
CONFIGARGS=""

# Create and set a configuration file that defines the authorization token.
if [ -n "$NGROK_AUTHTOKEN" ]; then
    cat > $CONFIGDIR/auth-config.yml <<EOF
    version: 3
    agent:
        authtoken: $NGROK_AUTHTOKEN
EOF
    CONFIGARGS="$CONFIGARGS --config=$CONFIGDIR/auth-config.yml"
fi

# Set the config file location; make sure agent uses default config even if NGROK_AUTHTOKEN is set
if [ -n "$NGROK_CONFIG" ]; then
    CONFIGARGS="$CONFIGARGS --config=$NGROK_CONFIG"
else
    CONFIGARGS="--config=$CONFIGDIR/ngrok.yml $CONFIGARGS"
fi

# When no custom args are used, just start every tunnel defined in the configuration files
if [ $# -eq 0 ]; then
    exec ngrok $CONFIGARGS start --all
else
    exec ngrok $CONFIGARGS "$@"
fi
