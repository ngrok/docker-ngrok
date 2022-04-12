# ngrok agent docker image

# Upgrading to v3

We recently rolled out a new version of the agent that requires some changes. You can find an [upgrade guide in our docs](https://ngrok.com/docs/guides/upgrade-v2-v3).

## Introduction

This repository contains code related to building and releasing the [ngrok docker image][ngrok-dockerhub]

Please visit [ngrok's website][ngrok] for more information on what ngrok is.

The [ngrok agent docs page][ngrok-docs] has more information on how to use the ngrok agent.

## Usage

### Run an ngrok agent pointed at localhost:80

...on Linux:

```bash
docker run --net=host -it ngrok/ngrok http 80
```

...on Windows or MacOS:

```bash
docker run -it ngrok/ngrok http host.docker.internal:80
```

### Access the web inspector on the host machine at localhost:3000

```bash
docker run -it -p 3000:4040 ngrok/ngrok http 80
```

### Run the ngrok agent with auth token 'xyz'

```bash
docker run -it -e NGROK_AUTHTOKEN=xyz ngrok/ngrok:alpine http 80
```

### Run the ngrok agent with the config file './ngrok.yml' from the host machine

```bash
docker run -it -v $(pwd)/ngrok.yml:/etc/ngrok.yml -e NGROK_CONFIG=/etc/ngrok.yml ngrok/ngrok:alpine http 80
```

## Tags

described [here][ngrok-dockerhub]

[ngrok-dockerhub]: https://hub.docker.com/r/ngrok/ngrok
[ngrok]: https://ngrok.com/
[ngrok-docs]: https://ngrok.com/docs
