# Copyright 2016-2017 LasLabs Inc.
# License Apache 2.0 (https://www.apache.org/licenses/LICENSE-2.0.html).

FROM golang:alpine
MAINTAINER Dave Lasley <dave@laslabs.com>

RUN apk add --update ca-certificates

COPY .ca-certificates/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

ENV CFSSL_CSR="csr_root_ca.json" \
    CFSSL_CONFIG="ca_root_config.json" \
    DB_CONFIG="db_config.json" \
    DB_DISABLED="0" \
    DB_DRIVER="sqlite3" \
    DB_ENVIRONMENT="production" \
    DB_INIT="1" \
    DB_DESTROY="0"

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

# Install Goose from github mirror because of bitbucket TLS issue on debian/ubuntu
RUN git config --global url."https://github.com/Toilal/bitbucket-liamstask-goose".insteadOf "https://bitbucket.org/liamstask/goose" \
    && go get bitbucket.org/liamstask/goose/cmd/goose \
    # Install CFSSL
    && git clone --depth=1 "https://github.com/cloudflare/cfssl.git" "${GOPATH}/src/github.com/cloudflare/cfssl" \
    && cd "${GOPATH}/src/github.com/cloudflare/cfssl" \
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
    # Cleanup
    && apk del .build-deps \
    && rm -rf "${GOPATH}/src"

# Create PKI directory and Create symlink CSR to root
RUN mkdir -p /etc/cfssl && ln -s "/etc/cfssl/${CFSSL_CSR}"

# Copy default CSR JSON
COPY docker-alpine-cfssl/etc/* /etc/cfssl/

# Copy Docker Entrypoint
COPY docker-alpine-cfssl/docker-entrypoint.sh /

# Copy binaries
COPY docker-alpine-cfssl/bin /cfssl-bin

# Create CFSSL User and Group   
RUN addgroup -g ${HOST_GID:-1000} -S cfssl && adduser -u ${HOST_UID:-1000} -S -g cfssl cfssl

# Directory/File permissions
RUN chown -R cfssl:cfssl /etc/cfssl \
    && chmod 770 /etc/cfssl \
    && chmod 644 /etc/cfssl/*.json \
    && chown cfssl:cfssl /docker-entrypoint.sh \
    && chmod 770 /docker-entrypoint.sh \
    && chown cfssl:cfssl /opt/certdb \
    && chown -R cfssl:cfssl /cfssl-bin \
    && chmod -R 770 /cfssl-bin \
    && ln -s /cfssl-bin/* /bin

# Switch from root user
USER "cfssl:cfssl"

# Change to PKI Dir
WORKDIR /etc/cfssl

# Exose ports & volumes
VOLUME ["/etc/cfssl"]
EXPOSE 8888

# Entrypoint & Command
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["cfssl", \
     "serve", \
     "-address=0.0.0.0", \
     "-ca=/etc/cfssl/ca.pem", \
     "-ca-key=/etc/cfssl/ca-key.pem"]
