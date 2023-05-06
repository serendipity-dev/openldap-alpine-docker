# OpenLDAP server on Alpine Linux

The Lightweight Directory Access Protocol (LDAP) is an open, vendor-neutral,
industry standard application protocol for accessing and maintaining
distributed directory information services over an Internet Protocol (IP)
network.

This image is based on Alpine Linux and OpenLDAP. 
This is a fork from the original image available at https://github.com/gitphill/ldap-alpine from Phill Garrett (https://github.com/gitphill).

## Customization

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
| TLS_VERIFY_CLIENT | Option for client certificate verification. Valid values are allow, try, never, demand | demand |
| CA_FILE | the CA's that openldap will trust |  |
| KEY_FILE | The openldap server private key |  |
| CERT_FILE | The openldap server certificate |  |

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


## Usage examples

Here follows some usage examples to get you up and running. These examples assume that you have a Debian Linux machine with docker installed and are familiar with its use.

### Set up and run openldap with minimal customization

First, create a folder to host your docker-compose.yml file and jump into it:

```console
mkdir -p /srv/docker-services/compose-openldap
cd /srv/docker-services/compose-openldap
```

Now build the folders to hold your ldap data and customizations:

```console
mkdir -p openldap/{data,schemas_ext,acs_ext,indexes_ext,certs,ldif}
```

Create a docker-compose.yml file so that it contains the openldap service definition based on the hakni/openldap-alpine image:

```console
touch docker-compose.yml
cat <<EOT >> docker-compose.yml
version: '3'

services:
  openldap:
    image: hakni/openldap-alpine:latest
    hostname: ldap.serendipity-dev.com
    network_mode: "bridge"
    restart: always
    environment:
      ORGANISATION_NAME: "Serendipity Development"
      SUFFIX: "dc=serendipity-dev,dc=com"
      ROOT_USER: "ldap_root_usr"
      ROOT_PW: "{CRYPT}%PASSWD%"
      LOG_LEVEL: "stats"
    volumes:
      - $PWD/openldap/certs:/etc/ssl/certs
      - $PWD/openldap/data:/var/lib/openldap/openldap-data
      - $PWD/openldap/ldif:/ldif
      - $PWD/openldap/schemas_ext:/etc/openldap/schemas_ext
      - $PWD/openldap/acs_ext:/etc/openldap/acs_ext
      - $PWD/openldap/indexes_ext:/etc/openldap/indexes_ext
EOT

```

Because the image is using a specific encryption scheme for passwords (password-crypt-salt-format "$6$rounds=50000$%.16s"), mkpasswd must be used to generate every password's hash. 

Check that mkpasswd is installed and install it if not (it is contained in whois package on Debian distributions):

```console
which mkpasswd || apt-get install whois
```

Choose a password for ldap_root_usr, apply some cryptography, and replace the %PASSWD% variable in doocker-compose.yml with it (properly escaping $ characters):

```console
mkpasswd --rounds 500000 -m sha-512 --salt `head -c 40 /dev/random | base64 | sed -e 's/+/./g' |  cut -b 10-25` 'DoNotUseThisPassword' > password.txt && history -d $(history 1)
sed -i 's/\$/\$\$/g' password.txt 
sed "s/%PASSWD%/$(sed -e 's/[\/&]/\\&/g' password.txt)/g" -i docker-compose.yml
rm password.txt
```

Start the container using the docker compose command:

```console
docker compose up -d
```

Show the IP of the container and store it in the openldapIP variable:

```console
openldapCID=$(docker ps -a | grep hakni/openldap-alpine | cut -c1-8)
openldapIP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $openldapCID)
echo $openldapIP
```

Check that ldapsearch is installed and install it if not (it is contained in ldap-utils package on Debian distributions):

```console
which ldapsearch || apt-get install ldap-utils
```

Query openldap to check everything is working:

```console
ldapsearch -h $openldapIP -D "cn=ldap_root_usr,dc=serendipity-dev,dc=com" -w DoNotUseThisPassword -b "dc=serendipity-dev,dc=com" "uid=hakni"  && history -d $(history 1)
```

If everything is correct, you should get an answer like this:

```console
# extended LDIF
#
# LDAPv3
# base <dc=serendipity-dev,dc=com> with scope subtree
# filter: uid=hakni
# requesting: ALL
#

# search result
search: 2
result: 0 Success

# numResponses: 1
```

### Add custom organizational units and users via ldif files

The folder mounted as /ldif can be used to customize organizational units and add users. Note that filenames are important to get the files in /ldif folder being loaded in the correct order.

Create a file named 1-ou.ldif into openldap/ldif folder so that it contains the definition of the Users organizational unit:

```console
cd /srv/docker-services/compose-openldap
touch openldap/ldif/1-ou.ldif
cat <<EOT >> openldap/ldif/1-ou.ldif
dn: ou=Users,dc=serendipity-dev,dc=com
objectClass: organizationalUnit
ou: Users
EOT
```

Create a file named 2-hakni.ldif into openldap/ldif folder so that it contains the definition of the hakni user:

```console
touch openldap/ldif/2-hakni.ldif
cat <<EOT >> openldap/ldif/2-hakni.ldif
dn: uid=hakni,ou=Users,dc=serendipity-dev,dc=com
cn: Alfredo Schiappa
objectclass: inetOrgPerson
objectclass: posixAccount
mail: hakni@serendipity-dev.com
homeDirectory: /home/hakni
loginShell: /bin/sh
ou: Users
givenName: Alfredo
sn: Schiappa
uid: hakni
uidNumber: 11001
gidNumber: 10001
userpassword: {CRYPT}%PASSWD%
EOT
```

Choose a password for hakni, apply some cryptography, and replace the %PASSWD% variable in 2-hakni.ldif with it:

```console
mkpasswd --rounds 500000 -m sha-512 --salt `head -c 40 /dev/random | base64 | sed -e 's/+/./g' |  cut -b 10-25` 'ForgetAboutIt' > password.txt && history -d $(history 1)
sed "s/%PASSWD%/$(sed -e 's/[\/&]/\\&/g' password.txt)/g" -i openldap/ldif/2-hakni.ldif
rm password.txt
```

Restart the container using the docker compose commands:

```console
docker compose down
docker compose up -d
```

Show the IP of the container and store it in the openldapIP variable:

```console
openldapCID=$(docker ps -a | grep hakni/openldap-alpine | cut -c1-8)
openldapIP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $openldapCID)
echo $openldapIP
```

Query openldap to check ldif files have been loaded:

```console
ldapsearch -h $openldapIP -D "cn=ldap_root_usr,dc=serendipity-dev,dc=com" -w DoNotUseThisPassword -b "dc=serendipity-dev,dc=com" "uid=hakni"  && history -d $(history 1)
```

You should also be able to use lsapsearch with the hakni user's credentials

```console
ldapsearch -h $openldapIP -D "uid=hakni,ou=Users,dc=serendipity-dev,dc=com" -w ForgetAboutIt -b "dc=serendipity-dev,dc=com" "uid=hakni"  && history -d $(history 1)
```

If everything is correct, you should get an answer like this:

```console
# extended LDIF
#
# LDAPv3
# base <dc=serendipity-dev,dc=com> with scope subtree
# filter: uid=hakni
# requesting: ALL
#

# hakni, Users, serendipity-dev.com
dn: uid=hakni,ou=Users,dc=serendipity-dev,dc=com
cn: Alfredo Schiappa
objectClass: inetOrgPerson
objectClass: posixAccount
mail: hakni@serendipity-dev.com
homeDirectory: /home/hakni
loginShell: /bin/sh
ou: Users
givenName: Alfredo
sn: Schiappa
uid: hakni
uidNumber: 11001
gidNumber: 10001
userPassword:: e0NSWVBUfSQ2JHJvdW5kcz01MDAwMDAkWllWWktGZDI4ZEUzN0NyLyRvV2ozaFV
 vdVVkdklzLzVVOHZVTVd5a3R5WlNRcHFnZUFmY3NxbGJBNHNrZHFtWHA5am9jUzdvajBQTTk3WmdD
 OXFITGZTMVMvZ3JBNDM3dnlqV2hSMA==

# search result
search: 2
result: 0 Success


# numResponses: 2
# numEntries: 1
```
