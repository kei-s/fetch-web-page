# Fetch Web Page

# Usage

## Setup

```
$ docker build -t fetch-web-page .
$ docker run -it --rm fetch-web-page:latest
```

## Save web pages

```
$ ./fetch <url> <...urls>
```

Example:

```
$ ./fetch https://www.google.com
$ ls
www.google.com.html
```

## Show page metadata

```
$ ./fetch --metadata <url> <...urls>
```

Example:

```
$ ./fetch --metadata https://www.google.com
Site: www.google.com
num_links: 18
images: 1
last_fetch: 2021-08-14T21:47:43+09:00
```

## Save pages and all assets

For this option, run docker container with port forwarding.

```
$ docker run -it --rm -p 8000:8000 fetch-web-page:latest
```

```
$ ./fetch --all-assets <url> <...urls>
```

Example:

```
$ ./fetch --all-assets https://www.google.com
$ ls
www.google.com/
```

If the page is HTTP, run below and access `http://localhost:8000`.

```
$ ./serve www.google.com
```

If the page is HTTPS, run below and access `https://localhost:8000`.
(This server uses [self-signed certificate](https://en.wikipedia.org/wiki/Self-signed_certificate), so you access at your own risk.)

```
$ ./serve --https www.google.com
```
