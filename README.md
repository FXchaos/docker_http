# docker_http

## Description

## License

This ... is licensed under the Apache License, Version 2.

## Prerequisites

* Docker is required. See the [official installation documentation](https://docs.docker.com/get-docker/){:target="_blank" rel="noopener"}.
* You need a free MaxMind account to download the [GeoLite2 databases](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data){:target="_blank" rel="noopener"}.

## Requirements



## Usage

Build an image:

```
docker build -t http --build-arg GEOLITE2_LICENSE_KEY= .
```

Run an image inside of a container:

```
docker run -p 80:80 http
```

## Copyright
