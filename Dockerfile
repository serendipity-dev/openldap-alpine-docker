FROM alpine:3.17.2

ENV ORGANISATION_NAME "Example Ltd"
ENV SUFFIX "dc=example,dc=com"
ENV ROOT_USER "admin"
ENV ROOT_PW "password"
ENV LOG_LEVEL "stats"

RUN apk add --update openldap openldap-back-mdb && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data && \
    rm -rf /var/cache/apk/*

COPY scripts/* /etc/openldap/
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 389
EXPOSE 636

VOLUME ["/ldif", "/var/lib/openldap/openldap-data", "/etc/ssl/certs", "/etc/openldap/acs_ext", "/etc/openldap/schemas_ext", "/etc/openldap/indexes_ext"]

ENTRYPOINT ["/docker-entrypoint.sh"]
