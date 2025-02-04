# Fork of nip.io

This is a fork of http://nip.io with some neat changes...

## About

Dead simple wildcard DNS for any IP Address

nip.io allows you to map any IP Address in the following DNS wildcard entries:

It works with Dashes `-`, perfect for wildcard TLS certs:
~~~
10-0-0-1.nip.io maps to 10.0.0.1
app.10-0-0-1.nip.io maps to 10.0.0.1
customer1.app.10-0-0-1.nip.io maps to 10.0.0.1
~~~

As well as Dot `.`:
~~~
10.0.0.1.nip.io maps to 10.0.0.1
app.10.0.0.1.nip.io maps to 10.0.0.1
customer1.app.10.0.0.1.nip.io maps to 10.0.0.1
~~~

See https://github.com/resmo/nip.io/blob/master/src/backend.conf.example for an example config-

**Hint**: See the static CNAME `_acme-challenge=xyz.auth.example.com.` in the example, use it with https://github.com/joohoi/acme-dns for free Let's Encrypt TLS certs.

## Install

### As Docker Container

#### Run the Container from ghcr:

Quick test run with built-in config for example.com:

```bash
docker run -d -p 0.0.0.0:5353:53/tcp -p 0.0.0.0:5353:53/udp --name nip.io ghcr.io/resmo/nip-io:latest
dig @localhost -p5353 10-1-2-3.example.com
```

Provide your own config as volume:

```bash
docker run -d -p 0.0.0.0:53:53/tcp -p 0.0.0.0:53:53/udp -v /data/backend.conf:/usr/local/bin/backend.conf --name nip.io ghcr.io/resmo/nip-io:latest
```

#### Or Build the Image:

```bash
docker build -t nip.io .
```

#### See the Logs:

```bash

docker logs -f nip.io
```

#### Test it

```bash
dig 1-2-3-4.example.com +short @localhost
1.2.3.4

dig foo.1-2-3-4.example.com +short @localhost
1.2.3.4
```

## License

Apache2 http://www.apache.org/licenses/LICENSE-2.0
