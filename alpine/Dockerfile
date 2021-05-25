FROM alpine:3.12
# based on https://github.com/wernight/docker-ngrok/blob/master/Dockerfile

RUN set -x \
    # Install ngrok (latest official stable from https://ngrok.com/download).
 && apk add --no-cache curl \
 && curl -Lo /ngrok.zip https://bin.equinox.io/a/23C61AUP19h/ngrok-2.3.40-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
    # Create non-root user.
 && adduser -h /home/ngrok -D -u 6737 ngrok

# Add config script.
COPY --chown=ngrok ngrok.yml /home/ngrok/.ngrok2/

USER ngrok
ENV USER=ngrok

# Basic sanity check.
RUN ngrok --version

EXPOSE 4040

CMD ["/bin/ngrok"]
