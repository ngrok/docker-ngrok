# ngrok agent docker image

[![Docker Pulls](https://img.shields.io/docker/pulls/ngrok/ngrok.svg)](https://hub.docker.com/r/ngrok/ngrok)

## Introduction

This repository contains the code for building and releasing the [ngrok docker image][ngrok-dockerhub].

ngrok is an API gateway cloud service that forwards traffic from internet-accessible endpoint URLs to applications running anywhere.

**Quick Links:**
- [ngrok website][ngrok]
- [ngrok docs][ngrok-docs]
- [ngrok Docker Hub repository][ngrok-dockerhub]

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

If you are unable to view the web inspection interface typically available at `https://localhost:4040`, you may need to map your host port `4040` to port `4040` on the container, for example:

```bash
docker run -p 4040:4040 -it -e NGROK_AUTHTOKEN=xyz ngrok/ngrok:latest http host.docker.internal:80
```

## Usage

### Basic Usage

The ngrok docker image wraps the ngrok agent executable. Read the documentation for the [ngrok agent CLI docs](https://ngrok.com/docs/agent/cli/) for all commands.

#### Run an ngrok agent pointed at localhost:80

```bash
docker run -it -e NGROK_AUTHTOKEN=your_token ngrok/ngrok http host.docker.internal:80
```

### Choose a URL

If you don't choose a URL, ngrok will assign one for you.

```bash
docker run -it -e NGROK_AUTHTOKEN=your_token ngrok/ngrok http host.docker.internal:80 --url https://your-url-here.ngrok.app
```

### Add a Traffic Policy

[Traffic Policy](https://ngrok.com/docs/traffic-policy/) is a configuration language that offers you the flexibility to filter, match, manage and orchestrate traffic to your endpoints.

```bash
docker run -it -v $(pwd)/traffic-policy.yml:/etc/traffic-policy.yml ngrok/ngrok:alpine http host.docker.internal:80 --traffic-policy-file /etc/traffic-policy.yml
```

##### `traffic-policy.yml`

```yaml
on_http_request:
  - actions:
      - type: basic-auth
        config:
          credentials:
            - user:password123
```

#### Run in the background

```bash
docker run -d --restart unless-stopped -e NGROK_AUTHTOKEN=your_token --name ngrok-agent ngrok/ngrok http host.docker.internal:80
```

### Use a configuration file

Run the ngrok agent with the config file `./ngrok.yml` from the host machine:

```bash
docker run -it -v $(pwd)/ngrok.yml:/etc/ngrok.yml -e NGROK_CONFIG=/etc/ngrok.yml ngrok/ngrok:alpine http host.docker.internal:80
```

#### Pull the ngrok container image

```bash
docker pull ngrok/ngrok
```

## Traffic Inspection

#### Traffic Inspector

Use [Traffic Inspector](https://dashboard.ngrok.com/ac_aHNlbPD0YUEUrqWbr9xZQJUflCx/traffic-inspector) on your ngrok dashboard

#### Local Web Inspection on localhost:4040 (Legacy)

The agent serves this web interface on port 4040 so you'll need to publish it as well with `-p 4040:4040`

```bash
docker run -it -p 4040:4040 ngrok/ngrok http host.docker.internal:80
```

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
