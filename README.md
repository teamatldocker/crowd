# Dockerized Atlassian Crowd

Work In Progress!

Image refactored, tag 2.8.4 deleted because of problems, now running version 2.8.3.

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
