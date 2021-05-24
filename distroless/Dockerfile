# based on https://github.com/wernight/docker-ngrok/blob/master/Dockerfile
FROM debian:buster-slim AS builder

RUN apt-get update && apt-get install curl -y
RUN curl -Lo ngrok.deb https://bin.equinox.io/a/ebw3zE8uejc/ngrok-2.3.40-linux-$(dpkg --print-architecture).deb
RUN dpkg -i ngrok.deb

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

FROM gcr.io/distroless/base
COPY --from=builder /bin/sh /bin/sh
COPY --from=builder /usr/local/bin/ngrok /usr/local/bin/ngrok

COPY ngrok.yml /home/ngrok/.ngrok2/
COPY --from=builder entrypoint.sh /entrypoint.sh

# sanity check.
RUN ngrok --version

EXPOSE 4040

CMD ["/entrypoint.sh", "/usr/local/bin/ngrok"]
