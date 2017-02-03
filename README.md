# Dockerized Atlassian Crowd

[![Circle CI](https://circleci.com/gh/blacklabelops/crowd/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/crowd/tree/master) [![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/crowd.svg)](https://hub.docker.com/r/blacklabelops/crowd/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/crowd.svg)](https://hub.docker.com/r/blacklabelops/crowd/)

"Users can come from anywhere: Active Directory, LDAP, Crowd itself, or any mix thereof. Control permissions to all your applications in one place – Atlassian, Subversion, Google Apps, or your own apps." - [[Source](https://www.atlassian.com/software/crowd/overview)]

## Supported tags and respective Dockerfile links

| Version | Tags  | Dockerfile |
|---------|-------|------------|
|  2.10.1  | 2.10.1, latest | [Dockerfile](https://github.com/blacklabelops/crowd/blob/master/Dockerfile) |

> Older tags remain but are not supported/rebuild.

## Related Images

You may also like:

* [blacklabelops/jira](https://github.com/blacklabelops/jira): The #1 software development tool used by agile teams
* [blacklabelops/confluence](https://github.com/blacklabelops/confluence): Create, organize, and discuss work with your team
* [blacklabelops/bitbucket](https://github.com/blacklabelops/bitbucket): Code, Manage, Collaborate
* [blacklabelops/crowd](https://github.com/blacklabelops/crowd): Identity management for web apps

# Make It Short

Docker-Compose:

~~~~
$ curl -O https://raw.githubusercontent.com/blacklabelops/crowd/master/docker-compose.yml
$ docker-compose up -d
~~~~

> Crowd will be available at http://yourdockerhost:8095

Docker-CLI:

Just type and follow the manual installation procedure in your browser:

~~~~
$ docker run -d -p 8095:8095 --name crowd blacklabelops/crowd
~~~~

> Point your browser to http://yourdockerhost:8095

# Setup

1. Start database server for Crowd.
1. Start Crowd.
1. Manual Crowd setup.

Firstly, start the database server for Crowd:

> Note: Change Password!

~~~~
$ docker run --name postgres_crowd -d \
    -e 'POSTGRES_DB=crowddb' \
    -e 'POSTGRES_USER=crowddb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    blacklabelops/postgres
~~~~

Secondly, start Crowd:

~~~~
$ docker run -d --name crowd \
	  --link postgres_crowd:postgres_crowd \
	  -p 8095:8095 blacklabelops/crowd
~~~~

>  Starts Crowd and links it to the postgresql instances. JDBC URL: jdbc:postgresql://postgres_crowd/crowddb

Thirdly, configure your Crowd yourself and fill it with a test license.

Point your browser to http://yourdockerhost:8095

1. Choose `Set up Crowd`
1. Create and enter license information
1. Choose `New installation`
1. In `Database configuration` choose `JDBC connection` and fill out the form:
  * Database: PostgreSQL
  * Driver Class Name: `org.postgresql.Driver`
  * JDBC URL: `jdbc:postgresql://postgres_crowd:5432/crowddb`
  * Username: `crowddb`
  * Password: `jellyfish`
  * Hibernate dialect: `org.hibernate.dialect.PostgreSQLDialect`
1. In `Options` choose `http://localhost:8095/crowd` for field `Base URL` otherwise you won't be able to connect later on.
1. Fill out the rest of the installation procedure.

# Disabling The Splash Context

Set the Splash Screens context to empty string and crowd to root context.

~~~~
$ docker run -d --name crowd \
    -e "CROWD_URL=http://localhost:8095" \
	  -e "SPLASH_CONTEXT=" \
    -e "CROWD_CONTEXT=ROOT" \
	  -p 8095:8095 blacklabelops/crowd
~~~~

> Splash context will never be shown, crowd will be shown under http://youdockerhost:8095/

# Disabling OpenID & Demo Contexts

Disable all contexts to make sub application inaccessible (e.g. you do not use them)

You can disable applications by setting their context to empty string:

* Crowd: CROWD_CONTEXT
* Splash: SPLASH_CONTEXT
* OpenID server: CROWDID_CONTEXT
* OpenID client: OPENID_CLIENT_CONTEXT

Example:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_URL=http://localhost:8095" \
    -e "SPLASH_CONTEXT=" \
    -e "CROWD_CONTEXT=ROOT" \
    -e "CROWDID_CONTEXT=" \
    -e "OPENID_CLIENT_CONTEXT=" \
	  -p 8095:8095 blacklabelops/crowd
~~~~

> Subapplications will not be accessible anymore. Crowd will run under root context under http://youdockerhost:8095/

# Proxy Configuration

You can specify your proxy host and proxy port with the environment variables CROWD_PROXY_NAME and CROWD_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use https then you also have to include the environment variable CROWD_PROXY_SCHEME.

Example HTTPS:

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_PROXY_NAME=myhost.example.com" \
    -e "CROWD_PROXY_PORT=443" \
    -e "CROWD_PROXY_SCHEME=https" \
    blacklabelops/crowd
~~~~

> Will set the values inside the server.xml in /opt/crowd/.../server.xml

# NGINX HTTP Proxy

This is an example on running Atlassian Crowd behind NGINX with 2 Docker commands!

First start Crowd:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_PROXY_NAME=192.168.99.100" \
    -e "CROWD_PROXY_PORT=80" \
    -e "CROWD_PROXY_SCHEME=http" \
    blacklabelops/crowd
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 80:80 \
    --name nginx \
    --link crowd:crowd \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://crowd:8095" \
    blacklabelops/nginx
~~~~

> Crowd will be available at http://192.168.99.100.

# NGINX HTTPS Proxy

This is an example on running Atlassian Crowd behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [blacklabelops/nginx](https://github.com/blacklabelops/nginx)

First start Crowd:

~~~~
$ docker run -d --name crowd \
    -e "CROWD_PROXY_NAME=192.168.99.100" \
    -e "CROWD_PROXY_PORT=80" \
    -e "CROWD_PROXY_SCHEME=http" \
    blacklabelops/crowd
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 443:443 \
    --name nginx \
    --link crowd:crowd \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://crowd:8095" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=CrustyClown/OU=SpringfieldEntertainment/O=crusty.springfield.com/L=Springfield/C=US" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    blacklabelops/nginx
~~~~

> Crowd will be available at https://192.168.99.100.

# More In-Depth Features

The full feature list is documented here as this image is feature identical with the atlassian example: [Readme.md](https://bitbucket.org/atlassianlabs/atlassian-docker/src/ee4a3434b1443ed4d9cfbf721ba7d4556da8c005/crowd/?at=master)

# Support

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](http://support.blacklabelops.com)

# Credits

This project is very grateful for code and examples from the repositories:

* [atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

# References

* [Atlassian Crowd](https://www.atlassian.com/software/crowd/overview/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
