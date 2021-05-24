FROM debian:buster-slim AS builder

RUN set -x \
 && apt-get update && apt-get install curl unzip -y \
 && curl -Lo /ngrok.zip https://bin.equinox.io/a/23C61AUP19h/ngrok-2.3.40-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip

FROM debian:buster-slim

RUN useradd ngrok && mkdir /var/lib/ngrok && chown ngrok /var/lib/ngrok
COPY --chown=ngrok ngrok.yml /var/lib/ngrok
COPY --from=builder /bin/ngrok /bin
COPY entrypoint.sh /

USER ngrok
ENV USER=ngrok

# sanity check.
RUN ngrok --version

EXPOSE 4040

ENTRYPOINT ["/entrypoint.sh"]
