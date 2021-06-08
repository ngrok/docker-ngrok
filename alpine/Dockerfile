FROM alpine:3.12

RUN set -x \
 && apk add --no-cache curl \
 && curl -Lo /ngrok.zip https://bin.equinox.io/a/23C61AUP19h/ngrok-2.3.40-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
 && adduser -h /home/ngrok -D -u 6737 ngrok \
 && mkdir /var/lib/ngrok \
 && chown ngrok /var/lib/ngrok

# Add config script.
COPY --chown=ngrok ngrok.yml /var/lib/ngrok
COPY entrypoint.sh /

USER ngrok
ENV USER=ngrok

# Basic sanity check.
RUN ngrok --version

EXPOSE 4040

ENTRYPOINT ["/entrypoint.sh"]
