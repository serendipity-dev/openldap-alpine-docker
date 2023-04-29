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
| TLS_VERIFY_CLIENT | Slapd option for client certificate verification. Valid values are allow, try, never, demand | demand |
| CA_FILE | the CA's that slapd will trust | /etc/ssl/certs/ca.pem |
| KEY_FILE | The slapd server private key | /etc/ssl/certs/public.key |
| CERT_FILE | The slapd server certificate | /etc/ssl/certs/public.crt |

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

| MOUNT POINT | DESCRIPTION | USAGE  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| `/etc/openldap/schemas_ext` | this is to hold extra schemas to include. By default this image already include _core_, _cosine_, _nis_ and _inetorgperson_ schemas. | Put the extra schemas into this folder together with a file named _schemas_includes.ext_ containing the include directives, for example: *include /etc/openldap/schemas_ext/postfix.schema* |  |
| `/etc/openldap/acs_ext` | this is to hold access control policies. The default policy allows anyone and everyone to read anything but restricts updates to rootdn. Of course rootdn can always read and write *everything*! | Write the access control policies into a file named _acs_includes.ext_ placed inside this folder, for example: *access to \* by \** |  |
| `/etc/openldap/indexes_ext` | this is to specify further indexes. By default the image specify an index only for _objectClass_ by equality.  | Write the index directives into a file named _indexes_includes.ext_ placed inside this folder, for example: *index mail eq,sub* |  |

### Mount point for customizing LDAP OU and accounts 

Use the following mount point to customizze LDAP OU and accounts 

| MOUNT POINT | DESCRIPTION | USAGE  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| `/ldif` | this is to hold any organizational unit and accounts definition. BY default no organization units and no accounts other than root are created. | Write organizational units and accounts definition into files with *ldif* extension. Note that files are loaded in the order given by the alpine's shell default sorting which is applied when iterating the directory's content. |  |

### Mount point for setting up LDAP Transport Layer Security certificates

| MOUNT POINT | DESCRIPTION | USAGE  | DEFAULT VALUE |
| :------- | :---------- | :------ | :------ |
| `/etc/ssl/certs` | this is to hold ca, private key and server certificates. | Place into this folder the ca, private key and server certificates files specified into the corresponding environment variables.  |  |

### Mount point for persisting data

The container uses a standard mdb backend. To persist this database outside the
container mount `/var/lib/openldap/openldap-data`

| MOUNT POINT | DESCRIPTION |
| :------- | :---------- |
| `/var/lib/openldap/openldap-data` | this is to hold the LDAP database. By default the container uses a standard mdb backend.  |

