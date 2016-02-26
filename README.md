# Dockerized Atlassian Crowd

# Make It Short

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

> Splash context will never be shown, crowd will be shown under http://youdockerhost/

# Disabling OpenID & Demo Contexts

Disable all contexts to make sub application inaccessible (e.g. you do not use them)

You can disable applications by setting der context to empty string:

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

> Subapplication will not be accessible anymore. Crowd will run under root context under http://youdockerhost/

# More In-Depth Features

The full feature list is documented here as this image is feature identical with the atlassian example: [Readme.md](https://bitbucket.org/atlassianlabs/atlassian-docker/src/ee4a3434b1443ed4d9cfbf721ba7d4556da8c005/crowd/?at=master)

# Support & Feature Requests

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

# Credits

This project is very grateful for code and examples from the repositories:

* [atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

# References

* [Atlassian Crowd](https://www.atlassian.com/software/crowd/overview/)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
