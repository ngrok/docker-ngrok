# based on https://github.com/wernight/docker-ngrok/blob/master/Dockerfile
FROM debian:buster-slim

RUN set -x \
    # Install ngrok (latest official stable from https://ngrok.com/download).
 && apt-get update && apt-get install curl unzip -y \
 && curl -Lo /ngrok.zip https://bin.equinox.io/a/23C61AUP19h/ngrok-2.3.40-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
    # Create non-root user.
 && useradd ngrok

COPY --chown=ngrok ngrok.yml /home/ngrok/.ngrok2/

USER ngrok
ENV USER=ngrok

# sanity check.
RUN ngrok --version

EXPOSE 4040

CMD ["/bin/ngrok"]
