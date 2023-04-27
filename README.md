# OpenLDAP server on Alpine Linux

The Lightweight Directory Access Protocol (LDAP) is an open, vendor-neutral,
industry standard application protocol for accessing and maintaining
distributed directory information services over an Internet Protocol (IP)
network.

This image is based on Alpine Linux and OpenLDAP. 
This is a fork from the original image available at https://github.com/gitphill/ldap-alpine from Phill Garrett (https://github.com/gitphill).

## Customisation

The LDAP server can be configured overriding environment variables and setting up some volumes at specific mount points.

### Environment variables for LDAP basic settings

Override the following environment variables when running the docker container to customise LDAP:

| VARIABLE | DESCRIPTION | DEFAULT VALUE |
| :------- | :---------- | :------ |
| ORGANISATION_NAME | Organisation name | Example Ltd |
| SUFFIX | Organisation distinguished name | dc=example,dc=com |
| ROOT_USER | Root username | admin |
| ROOT_PW | Root password | password |
| LOG_LEVEL | LDAP logging level, see below for valid values. | stats |
| TLS_VERIFY_CLIENT | Slapd option for client certificate verification | try, never, demand |

#### Logging Levels

| NAME | DESCRIPTION |
| :--- | :---------- |
| any | enable all debugging (warning! lots of messages will be output) |
| trace | trace function calls |
| packets | debug packet handling |
| args | heavy trace debugging |
| conns | connection management |
| BER | print out packets sent and received |
| filter | search filter processing |
| config | configuration processing |
| ACL | access control list processing |
| stats | stats log connections/operations/results |
| stats2 | stats log entries sent |
| shell | print communication with shell backends |
| parse | print entry parsing debugging |
| sync | syncrepl consumer processing |
| none | only messages that get logged whatever log level is set |

### Mount points for customizing LDAP schemas, access control and indexes 

Use the following mount points to customizze LDAP schemas, access control and indexes 

| MOUNT POINT | DESCRIPTION | PRESCRIPTED CONTENT  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| /etc/openldap/schemas_ext/ |  |  | :------ |
| /etc/openldap/acs_ext/ |  |  | :------ |
| /etc/openldap/indexes_ext/ |  |  | :------ |

The default policy allows anyone and everyone to read anything but restricts updates to rootdn.
```
access to * by * read
```

Note rootdn can always read and write *everything*!

You can find detailed documentation on access control here https://www.openldap.org/doc/admin24/access-control.html



### Mount point for customizing LDAP OU and accounts 

Use the following mount point to customizze LDAP OU and accounts 

| MOUNT POINT | DESCRIPTION | PRESCRIPTED CONTENT  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| /ldif/ |  |  | :------ |

### Mount point for setting up LDAP Transport Layer Security certificates

| MOUNT POINT | DESCRIPTION | PRESCRIPTED CONTENT  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| //etc/ssl/certs/ |  |  | :------ |


| CA_FILE | PEM-format file containing certificates for the CA's that slapd will trust | /etc/ssl/certs/ca.pem |
| KEY_FILE | The slapd server private key | /etc/ssl/certs/public.key |
| CERT_FILE | The slapd server certificate | /etc/ssl/certs/public.crt |


### Mount point for persisting data

The container uses a standard mdb backend. To persist this database outside the
container mount `/var/lib/openldap/openldap-data`

| MOUNT POINT | DESCRIPTION | PRESCRIPTED CONTENT  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| /var/lib/openldap/openldap-data |  |  | :------ |

