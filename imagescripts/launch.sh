#!/bin/bash
set -o errexit

. /home/crowd/common.sh

cd ${CROWD_INSTALL}/apache-tomcat/conf/Catalina/localhost
for k in $(ls) ; do
  unlink $k
done

if [ -n "$DEMO_CONTEXT" ]; then
  echo "Installing demo at $DEMO_CONTEXT"
  ln -s /opt/crowd/webapps/demo.xml ${DEMO_CONTEXT}.xml
fi

if [ -n "$SPLASH_CONTEXT" ]; then
  echo "Installing splash as $SPLASH_CONTEXT"
  ln -s /opt/crowd/webapps/splash.xml ${SPLASH_CONTEXT}.xml
fi

if [ -n "$OPENID_CLIENT_CONTEXT" ]; then
  echo "Installing OpenID client at $OPENID_CLIENT_CONTEXT"
  ln -s /opt/crowd/webapps/openidclient.xml ${OPENID_CLIENT_CONTEXT}.xml
fi

if [ -n "$CROWDID_CONTEXT" ]; then
  echo "Installing OpenID server at $CROWDID_CONTEXT"
  ln -s /opt/crowd/webapps/openidserver.xml ${CROWDID_CONTEXT}.xml
fi

if [ -n "$CROWD_CONTEXT" ]; then
  echo "Installing Crowd at $CROWD_CONTEXT"
  ln -s /opt/crowd/webapps/crowd.xml ${CROWD_CONTEXT}.xml
fi
cd /opt/crowd

if [ -z "$DEMO_LOGIN_URL" ]; then
  if [ "$DEMO_CONTEXT" == "ROOT" ]; then
    DEMO_LOGIN_URL="$LOGIN_BASE_URL/"
  else
    DEMO_LOGIN_URL="$LOGIN_BASE_URL/$DEMO_CONTEXT"
  fi
fi

if [ -z "$CROWDID_LOGIN_URL" ]; then
  if [ "$CROWDID_CONTEXT" == "ROOT" ]; then
    CROWDID_LOGIN_URL="$LOGIN_BASE_URL/"
  else
    CROWDID_LOGIN_URL="$LOGIN_BASE_URL/$CROWDID_CONTEXT"
  fi
fi

config_line() {
    local key="$(echo $2 | sed -e 's/[]\/()$*.^|[]/\\&/g')"
    if [ -n "$3" ]; then
      local value="$(echo $3 | sed -e 's/[\/&]/\\&/g')"
      sed -i -e "s/^$key\s*=\s*.*/$key=$value/" $1
    else
      sed -n -e "s/^$key\s*=\s*//p" $1
    fi
}

if [ -n "$CROWD_CONTEXT" ]; then
  if [ -z "$CROWDDB_URL" -a -n "$DATABASE_URL" ]; then
    used_database_url=1
    CROWDDB_URL="$DATABASE_URL"
  fi
  if [ -n "$CROWDDB_URL" ]; then
    extract_database_url "$CROWDDB_URL" CROWDDB /opt/crowd/apache-tomcat/lib
    CROWDDB_JDBC_URL="$(xmlstarlet esc "$CROWDDB_JDBC_URL")"
    cat << EOF > webapps/crowd.xml
    <Context docBase="../../crowd-webapp" useHttpOnly="true">
      <Resource name="jdbc/CrowdDS" auth="Container" type="javax.sql.DataSource"
                username="$CROWDDB_USER"
                password="$CROWDDB_PASSWORD"
                driverClassName="$CROWDDB_JDBC_DRIVER"
                url="$CROWDDB_JDBC_URL"
              />
    </Context>
EOF
  fi
fi

if [ -n "$CROWDID_CONTEXT" ]; then
  if [ -z "$CROWDIDDB_URL" -a -n "$DATABASE_URL" ]; then
    if [ -n "$used_database_url" ]; then
      echo "DATABASE_URL is ambiguous since both Crowd and CrowdID are enabled."
      echo "Please use CROWDIDDB_URL and CROWDDB_URL instead."
      exit 2
    fi
    CROWDIDDB_URL="$DATABASE_URL"
  fi
  if [ -n "$CROWDIDDB_URL" ]; then
    extract_database_url "$CROWDIDDB_URL" CROWDIDDB "/opt/crowd/apache-tomcat/lib"
    CROWDIDDB_JDBC_URL="$(xmlstarlet esc "$CROWDIDDB_JDBC_URL")"
    cat << EOF > webapps/openidserver.xml
    <Context docBase="../../crowd-openidserver-webapp">
      <Resource name="jdbc/CrowdIDDS" auth="Container" type="javax.sql.DataSource"
                username="$CROWDIDDB_USER"
                password="$CROWDIDDB_PASSWORD"
                driverClassName="$CROWDIDDB_JDBC_DRIVER"
                url="$CROWDIDDB_JDBC_URL"
              />
    </Context>
EOF
    config_line build.properties hibernate.dialect "$CROWDIDDB_DIALECT"
  fi
fi

config_line build.properties demo.url "$DEMO_LOGIN_URL"
config_line build.properties openidserver.url "$CROWDID_LOGIN_URL"
config_line build.properties crowd.url "$CROWD_URL"

./build.sh

if [ -f "${CROWD_HOME}/crowd.properties" ]; then
  config_line /opt/atlassion-home/crowd.properties crowd.server.url "$(config_line crowd-webapp/WEB-INF/classes/crowd.properties crowd.server.url)"
  config_line /opt/atlassion-home/crowd.properties application.login.url "$(config_line crowd-webapp/WEB-INF/classes/crowd.properties application.login.url)"
fi

apache-tomcat/bin/catalina.sh run
