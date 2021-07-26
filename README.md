# docker_http

## Description

## License

This project is licensed under the ISC License.

## Prerequisites

* Docker is required. See the [official installation documentation](https://docs.docker.com/get-docker/).
* You need a free MaxMind account to download the [GeoLite2 databases](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data).

## Requirements

* Get your active MaxMind license key (`<YOUR_LICENSE_KEY>`).

## Usage

Build an image:

```
docker build -t http --build-arg HTTP__KEY_LICENSE_GEOLITE2=<YOUR_LICENSE_KEY> .
```

Run an image inside of a container:

```
docker run -p 80:80 http
```

## Copyright
