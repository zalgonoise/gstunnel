FROM alpine:edge

LABEL maintainer="Zalgo Noise <zalgo.noise@gmail.com>"
LABEL version="1.0"
LABEL description="STunnel Docker image compatible with Google G Suite SLDAP tunneling."

RUN apk add --update --no-cache stunnel libressl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
