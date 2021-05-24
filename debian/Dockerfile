# based on https://github.com/wernight/docker-ngrok/blob/master/Dockerfile
FROM debian:buster-slim

RUN apt-get update && apt-get install curl -y
RUN curl -Lo ngrok.deb https://bin.equinox.io/a/ebw3zE8uejc/ngrok-2.3.40-linux-$(dpkg --print-architecture).deb
RUN dpkg -i ngrok.deb

RUN useradd ngrok
COPY --chown=ngrok ngrok.yml /home/ngrok/.ngrok2/
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER ngrok
ENV USER=ngrok

# sanity check.
RUN ngrok --version

EXPOSE 4040

CMD ["/entrypoint.sh", "/usr/local/bin/ngrok"]
