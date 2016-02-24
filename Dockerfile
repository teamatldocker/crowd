FROM blacklabelops/java:jre7
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ARG CROWD_VERSION=2.8.4

ENV CROWD_HOME=/var/atlassian/crowd \
    CROWD_INSTALL=/opt/crowd \
    CROWD_URL=http://localhost:8095/crowd \
    LOGIN_BASE_URL=http://localhost:8095 \
    CROWD_CONTEXT=crowd \
    CROWDID_CONTEXT=openidserver \
    OPENID_CLIENT_CONTEXT=openidclient \
    DEMO_CONTEXT=demo \
    SPLASH_CONTEXT=ROOT

RUN apk add --update \
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
    echo "crowd.home = ${CROWD_HOME}" > ${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties && \
    mv ${CROWD_INSTALL}/apache-tomcat/webapps/ROOT ${CROWD_INSTALL}/splash-webapp && \
    mv ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost ${CROWD_INSTALL}/webapps && \
    mkdir -p ${CROWD_HOME} && \
    mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      gzip \
      wget &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* &&  \
    rm -rf /tmp/* &&  \
    rm -rf /var/log/*

ADD splash-context.xml /opt/crowd/webapps/splash.xml

WORKDIR /var/atlassian/crowd
#VOLUME ["/var/atlassian/crowd","/opt/crowd/apache-tomcat/logs"]
VOLUME ["/var/atlassian/crowd"]
EXPOSE 8095
COPY imagescripts /opt/crowd
ENTRYPOINT ["/opt/crowd/docker-entrypoint.sh"]
CMD ["crowd"]
