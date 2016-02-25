FROM blacklabelops/java:jre7
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ARG CROWD_VERSION=2.8.3
# permissions
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

ENV CROWD_HOME=/var/atlassian/crowd \
    CROWD_INSTALL=/opt/crowd \
    CROWD_PROXY_NAME= \
    CROWD_PROXY_PORT= \
    CROWD_PROXY_SCHEME=

RUN export MYSQL_DRIVER_VERSION=5.1.38 && \
    export POSTGRESQL_DRIVER_VERSION=9.4.1207 && \
    export CONTAINER_USER=crowd &&  \
    export CONTAINER_GROUP=crowd &&  \
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP &&  \
    adduser -u $CONTAINER_UID \
            -G $CONTAINER_GROUP \
            -h /home/$CONTAINER_USER \
            -s /bin/bash \
            -S $CONTAINER_USER &&  \
    apk add --update \
      ca-certificates \
      gzip \
      wget &&  \
    apk add xmlstarlet --update-cache \
      --repository \
      http://dl-3.alpinelinux.org/alpine/edge/testing/ \
      --allow-untrusted &&  \
    wget -O /tmp/crowd.tar.gz https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${CROWD_VERSION}.tar.gz && \
    tar zxf /tmp/crowd.tar.gz -C /tmp && \
    mv /tmp/atlassian-crowd-${CROWD_VERSION} /tmp/crowd && \
    mv /tmp/crowd /opt/crowd && \
    mkdir -p ${CROWD_HOME} && \
    mkdir -p ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes && \
    echo "crowd.home=${CROWD_HOME}" > ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties && \
    # Install database drivers
    rm -f \
      ${CROWD_INSTALL}/apache-tomcat/lib/mysql-connector-java*.jar &&  \
    wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
      http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz && \
    tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
      -C /tmp && \
    cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar \
      ${CROWD_INSTALL}/apache-tomcat/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar  &&  \
    rm -f ${CROWD_INSTALL}/lib/postgresql-*.jar &&  \
    wget -O ${CROWD_INSTALL}/apache-tomcat/lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
      https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar && \
    # Adjusting directories
    mv ${CROWD_INSTALL}/apache-tomcat/webapps/ROOT /opt/crowd/splash-webapp && \
    mv ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost /opt/crowd/webapps && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost
ADD splash-context.xml /opt/crowd/webapps/splash.xml
RUN chown -R crowd:crowd ${CROWD_HOME} && \
    chown -R crowd:crowd ${CROWD_INSTALL} && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      gzip \
      wget &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

ENV CROWD_URL=http://localhost:8095/crowd \
    LOGIN_BASE_URL=http://localhost:8095 \
    CROWD_CONTEXT=crowd \
    CROWDID_CONTEXT=openidserver \
    OPENID_CLIENT_CONTEXT=openidclient \
    DEMO_CONTEXT=demo \
    SPLASH_CONTEXT=ROOT

USER crowd
WORKDIR /var/atlassian/crowd
VOLUME ["/var/atlassian/crowd"]
EXPOSE 8095
COPY imagescripts /home/crowd
ENTRYPOINT ["/home/crowd/docker-entrypoint.sh"]
CMD ["crowd"]
