# Copyright 2016-2017 LasLabs Inc.
# License Apache 2.0 (https://www.apache.org/licenses/LICENSE-2.0.html).

FROM golang:alpine
MAINTAINER Dave Lasley <dave@laslabs.com>

RUN apk add --update ca-certificates

COPY .ca-certificates/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

ENV GIT_SSL_CAPATH="/etc/ssl/certs/ca-certificates.crt"
ENV SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"

ENV CFSSL_CSR="csr_root_ca.json" \
    CFSSL_CONFIG="ca_root_config.json" \
    DB_CONFIG="db_config.json" \
    DB_ENVIRONMENT="production" \
    DB_INIT="1" \
    DB_DESTROY="0"

# Copy Docker Entrypoint
COPY docker-alpine-cfssl/docker-entrypoint.sh /

# Copy default CSR JSON
COPY docker-alpine-cfssl/etc/* /etc/cfssl/

# Copy binaries
COPY docker-alpine-cfssl/bin /cfssl-bin

# Install Build Dependencies
RUN apk add --no-cache --virtual .build-deps \
        build-base \
        gcc \
        git \
        libtool \
        sqlite-dev \
# Install curl and python for API interaction
    && apk add --no-cache \
        curl \
        python

# Create CFSSL User and Group   
RUN addgroup -g ${HOST_GID:-1000} -S cfssl && adduser -u ${HOST_UID:-1000} -S -g cfssl cfssl

RUN git config --global http.sslCaInfo "/etc/ssl/certs/ca-certificates.crt"

# Install Goose
RUN git config --global url."https://github.com/Toilal/bitbucket-liamstask-goose".insteadOf "https://bitbucket.org/liamstask/goose"
RUN go get bitbucket.org/liamstask/goose/cmd/goose
#RUN git clone https://github.com/Toilal/bitbucket-liamstask-goose.git "${GOPATH}/src/bitbucket.org/liamstask/goose" && cd "${GOPATH}/src/bitbucket.org/liamstask/goose/cmd/goose" && go install

# Install CFSSL
RUN git clone --depth=1 "https://github.com/cloudflare/cfssl.git" "${GOPATH}/src/github.com/cloudflare/cfssl"
RUN cd "${GOPATH}/src/github.com/cloudflare/cfssl" \
	&& go build -o /usr/bin/cfssl ./cmd/cfssl \
	&& go build -o /usr/bin/cfssljson ./cmd/cfssljson \
	&& go build -o /usr/bin/mkbundle ./cmd/mkbundle \
	&& go build -o /usr/bin/multirootca ./cmd/multirootca \
# Move database migrations to /opt
    && mkdir /opt/ \
    && cp -R "${GOPATH}/src/github.com/cloudflare/cfssl/certdb/" /opt/ \
# Install go.rice
    && set -x \
	&& go get github.com/GeertJohan/go.rice/rice \
    && rice embed-go -i=./cli/serve \
# Create PKI directory
	&& mkdir -p /etc/cfssl \
# Create symlink CSR to root
    && ln -s "/etc/cfssl/${CFSSL_CSR}" / \
# Directory/File permissions
    && chown -R cfssl:cfssl /etc/cfssl \
    && chmod 770 /etc/cfssl \
    && chmod 644 /etc/cfssl/*.json \
    && chown cfssl:cfssl /docker-entrypoint.sh \
    && chmod 770 /docker-entrypoint.sh \
    && chown cfssl:cfssl /opt/certdb \
    && chown -R cfssl:cfssl /cfssl-bin \
    && chmod -R 770 /cfssl-bin \
# Add Binaries to /bin
    && ln -s /cfssl-bin/* /bin \
# Cleanup
	&& apk del .build-deps \
	&& rm -rf "${GOPATH}/src"

# Switch from root user
USER "cfssl:cfssl"

# Change to PKI Dir
WORKDIR /etc/cfssl

# Exose ports & volumes
VOLUME ["/etc/cfssl"]
EXPOSE 8080

# Entrypoint & Command
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["cfssl", \
     "serve", \
     "-address=0.0.0.0", \
     "-ca=/etc/cfssl/ca.pem", \
     "-ca-key=/etc/cfssl/ca-key.pem", \
     "-port=8080"]

# Metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="CFSSL - Alpine" \
      org.label-schema.description="Provides a Docker image for CFSSL based on Alpine Linux." \
      org.label-schema.url="https://laslabs.com/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/LasLabs/docker-alpine-cfssl" \
      org.label-schema.vendor="LasLabs Inc." \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"
