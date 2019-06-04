# Copyright 2016-2017 LasLabs Inc.
# License Apache 2.0 (https://www.apache.org/licenses/LICENSE-2.0.html).

FROM gficentreouest/alpine-cfssl

USER root
# WORKDIR /

# fixuid
ADD fixuid.tar.gz /usr/local/bin
RUN chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid
COPY cfssl/fixuid.yml /etc/fixuid/config.yml

COPY /cfssl/copy-root-ca-certificate.sh /

RUN chown -R cfssl:cfssl /etc/cfssl && chown -R cfssl:cfssl /cfssl-bin && chown -R cfssl:cfssl /cfssl_trust

RUN sed -i 's|set -e|set -e\necho "id: $(id)\ncd /etc/cfssl\n"|g' /docker-entrypoint.sh
RUN sed -i 's|exec "$@"|. /copy-root-ca-certificate.sh\n\nexec "$@"|g' /docker-entrypoint.sh

USER "cfssl:cfssl"
