# based on https://github.com/wernight/docker-ngrok/blob/master/Dockerfile
FROM debian:buster-slim AS builder

RUN set -x \
    # Install ngrok (latest official stable from https://ngrok.com/download).
 && apt-get update && apt-get install curl unzip -y \
 && curl -Lo /ngrok.zip https://bin.equinox.io/a/23C61AUP19h/ngrok-2.3.40-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip
    # Create non-root user.

FROM gcr.io/distroless/base

COPY --from=builder /bin/ngrok /bin
COPY ngrok.yml /home/ngrok/.ngrok2/

EXPOSE 4040

CMD ["/bin/ngrok"]
