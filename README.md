# ngrok agent docker image

[![Docker Pulls](https://img.shields.io/docker/pulls/ngrok/ngrok.svg)](https://hub.docker.com/r/ngrok/ngrok)

## Introduction

This repository contains the code for building and releasing the [ngrok docker image][ngrok-dockerhub].

ngrok is an API gateway cloud service that forwards traffic from internet-accessible endpoint URLs to applications running anywhere.

**Quick Links:**
- [ngrok website][ngrok]
- [ngrok docs][ngrok-docs]
- [ngrok Docker Hub repository][ngrok-dockerhub]

## Tags

We offer the following image tags. All tags below are multi-architecture and come in 32- and 64-bit flavors for both ARM and x86.

- `:latest`, :`debian` - The latest Debian-based build of the ngrok agent.
- `:alpine` - The latest Alpine-based build of the ngrok agent.
- `:3, :3-debian` - The latest Debian build for version 3 of the ngrok agent. Available for every major version from v3 and up.
- `:3-alpine` - The latest Alpine build for version 3 of the ngrok agent. Available for every major version from v3 and up.
- `:3.25.1-debian` - The latest Debian build for version 3.25.1 of the ngrok agent. Available for every minor version from 2.3.40 and up.
- `:3.25.1-alpine` - The latest Alpine build for version 3.25.1 of the ngrok agent. Available for every minor version from 2.3.40 and up.
- `:3.25.1-debian-d2827ad` - An immutable tag pointing to a Debian build of agent version 3.25.1 with build hash d2827ad. Available for every build we release.
- `:3.25.1-alpine-d2827ad` - An immutable tag pointing to an Alpine build of agent version 3.25.1 with build hash d2827ad. Available for every build we release.

## Quick Start

### Linux

```bash
# Forward a public endpoint URL to port 80 on your local machine
docker run --net=host -it -e NGROK_AUTHTOKEN=xyz ngrok/ngrok:latest http 80
```

### Windows or macOS

```bash
docker run -it -e NGROK_AUTHTOKEN=xyz ngrok/ngrok:latest http host.docker.internal:80
```

For macOS and Windows, you must use the special URL `host.docker.internal` as described in the [Docker networking documentation](https://docs.docker.com/desktop/features/networking/#use-cases-and-workarounds).

This also applies to the `upstream.url` endpoint property in your ngrok config file. For example:

```yml
endpoints:
  - name: example
    url: https://example.ngrok.app
    upstream:
      url: http://host.docker.internal:80
```

## Usage

For usage, see [Using ngrok with Docker](https://ngrok.com/docs/using-ngrok-with/docker/).

## Configuration

### Environment Variables

- `NGROK_AUTHTOKEN`: Your ngrok authentication token
- `NGROK_CONFIG`: Path to configuration file (default: `/etc/ngrok.yml`). See: [config file docs](ngrok-config-docs)


## Upgrading to v3

If you're using a v2 agent still, follow the [upgrade guide in our docs](https://ngrok.com/docs/guides/upgrade-v2-v3).


#### How do I know what version my ngrok container image is?

```bash
docker run -it ngrok/ngrok version
```

[ngrok-dockerhub]: https://hub.docker.com/r/ngrok/ngrok
[ngrok]: https://ngrok.com/
[ngrok-docs]: https://ngrok.com/docs
[ngrok-config-docs]: https://ngrok.com/docs/agent/config/
