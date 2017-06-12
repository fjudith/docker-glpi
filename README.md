# Supported tags and respective Dockerfile links

[`9.1.3`, latest](https://github.com/fjudith/docker-glpi/tree/9.1.3)
[`9.1.2`](https://github.com/fjudith/docker-glpi/tree/9.1.2)
[`9.1.1`](https://github.com/fjudith/docker-glpi/tree/9.1.1)


# Introduction

GLPI (formely Gestion Libre de Parc Infortique) is the most free & open source IT asset and service management tool available on the web.

It supports various languages, provides a configuration management database for various devices (CMDB for computer, software, printers, etc.) and enables an online administration interface to manage assets and tickets via a Webrowser.

GLPI can leverage LDAP protocol to manage the access and supports IMAP protocol to let end-users to create issues via email.


 # Description
The Dockerfile builds from "php:5-apache (see https://hub.docker.com/_/php/)

**This image does not leverage embedded database**

## Quick Start

Run a supported database container with persistent storage (i.e. MySQL, MariaDB).

```bash
docker volume create "glpi-db"

docker run --name='glpi-md' -d \
--restart=always \
-e MYSQL_DATABASE=glpi \
-e MYSQL_ROOT_PASSWORD=V3rY1ns3cur3P4ssw0rd \
-e MYSQL_USER=glpi \
-e MYSQL_PASSWORD=V3rY1ns3cur3P4ssw0rd \
-v glpi-db:/var/lib/mysql \
-v glpi-dblog:/var/log/mysql \
-v glpi-etc:/etc/mysql \
mariadb
```

Run the GLPI container exposing internal port 80 with persistent storage for _files_ folder (i.e for Software deployment packages).

```bash
docker volume create "glpi-files"

docker run --name='files' -d \
--restart=always \
-p 32706:80 \
-v glpi-files:/var/www/html/files \
--links glpi-md:mysql \
fjudith/glpi
```

## Initial configuration

1. Start a web browser session to http://ip:port
2. Select your language, then click _OK_.
3. Select _I have read and ACCEPT the terms of the license written above._ option, then click _Continue_.
4. Click on _Install_.
5. Review the requirement check-list, then click _Continue_.
6. Full-fill the following fields:
* **SQL server (MariaDB or MySQL)**: mysql
* **Database user**: glpi
* **Database password**: V3rY1ns3cur3P4ssw0rd
7. Then click _Continue_.
8. Select `glpi` database, then click _Continue_.
9. Confirm that message `OK - database was initialized` appears, then click _Continue_.
10. Click on _Use GLPI_.
11. Logon as `glpi` with password `glpi`.


# Docker-Compose
You can use docker compose to automate the above command if you create a file called docker-compose.yml and put in there the following:

```yaml
glpi-md:
  image: mariadb
  restart: always
  ports:
    - "32806:3306"
  environment:
    MYSQL_DATABASE: glpi
    MYSQL_ROOT_PASSWORD: V3rY1ns3cur3P4ssw0rd
    MYSQL_USER: glpi
    MYSQL_PASSWORD: V3rY1ns3cur3P4ssw0rd
  volumes:
  - glpi-db:/var/lib/mysql
  - glpi-dblog:/var/log/mysql
  - glpi-dbetc:/etc/mysql

glpi:
  image: fjudith/glpi
  restart: always
  ports:
    - "32706:80"
  volumes:
    - glpi-files:/var/www/html/files
    - glpi-plugins:/var/www/html/plugins
  links:
    - glpi-md:mysql
```

And run:

```bash
docker-compose up -d
```

# References

* http://glpi-project.org/spip.php?lang=en