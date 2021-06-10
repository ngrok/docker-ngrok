with import (import ./pkgs.nix) { };
let
  configDir = ".lib-ngrok";
  ngrokBin = fetchzip {
    # these will be moved to input values that will be passed in when we call `nix-build` from `nd`
    url = "https://bin.equinox.io/a/23C61AUP19h/ngrok-2.3.40-linux-amd64.zip";
    sha256 = "18zljspwkz2kxnaq3h5xk0n6zv4vrjhd9pay4zhcxlw54sgrqmb6";
  };
  extraCommands = ''
    mkdir -p ${configDir}
    chmod a+rw -R ${configDir}
    echo "web_addr: 0.0.0.0:4040" > ${configDir}/ngrok.yml
  '';
  shadowSetup = with pkgs; [
    (writeTextDir "etc/shadow" ''
      root:!x:::::::
      ngrok:!:::::::
    '')
    (writeTextDir "etc/passwd" ''
      root:x:0:0::/root:/bin/bash
      ngrok:x:1000:100::/home/ngrok:
    '')
    (writeTextDir "etc/group" ''
      root:x:0:
      ngrok:x:100:
    '')
    (writeTextDir "etc/gshadow" ''
      root:x::
      ngrok:x::
    '')
  ];
  entrypoint = ''
    #!/bin/sh
    ARGS=""

    # Set the authorization token.
    if [ -n "$NGROK_AUTHTOKEN" ]; then
      cat > ${configDir}/auth-config.yml <<EOF
      authtoken: $NGROK_AUTHTOKEN
    EOF
      ARGS="$ARGS --config=${configDir}/auth-config.yml"
    fi

    # Set the config file location; make sure agent uses default config even if NGROK_AUTHTOKEN is set
    if [ -n "$NGROK_CONFIG" ]; then
      ARGS="$ARGS --config=$NGROK_CONFIG"
    else
      ARGS="--config=${configDir}/ngrok.yml $ARGS"
    fi

    exec "${ngrokBin}/ngrok" "$@" $ARGS
  '';
in {
  debian = import ./debian.nix {
    inherit pkgs entrypoint extraCommands ngrokBin configDir shadowSetup;
  };
  alpine = import ./alpine.nix {
    inherit pkgs entrypoint extraCommands ngrokBin configDir shadowSetup;
  };
}
