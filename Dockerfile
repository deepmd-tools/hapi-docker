FROM hapiproject/hapi:base as build-hapi

ARG HAPI_FHIR_URL=https://github.com/jamesagnew/hapi-fhir/
ARG HAPI_FHIR_BRANCH=v5.0.0
ARG HAPI_FHIR_STARTER_URL=https://github.com/hapifhir/hapi-fhir-jpaserver-starter/
ARG HAPI_FHIR_STARTER_BRANCH=master

# Build HAPI
RUN git clone --branch ${HAPI_FHIR_BRANCH} ${HAPI_FHIR_URL}
WORKDIR /tmp/hapi-fhir/
RUN /tmp/apache-maven-3.6.2/bin/mvn dependency:resolve
RUN /tmp/apache-maven-3.6.2/bin/mvn install -DskipTests

# Build HAPI_FHIR_STARTER
WORKDIR /tmp
RUN git clone --branch ${HAPI_FHIR_STARTER_BRANCH} ${HAPI_FHIR_STARTER_URL}
COPY ./tmpl-banner.html /tmp/hapi-fhir-jpaserver-starter/src/main/webapp/WEB-INF/templates/tmpl-banner.html
COPY ./smart-logo.svg   /tmp/hapi-fhir-jpaserver-starter/src/main/webapp/img/smart-logo.svg
WORKDIR /tmp/hapi-fhir-jpaserver-starter
RUN /tmp/apache-maven-3.6.2/bin/mvn clean install -DskipTests

FROM tomcat:9-jre11

RUN mkdir -p /data/hapi/lucenefiles && chmod 775 /data/hapi/lucenefiles
COPY --from=build-hapi /tmp/hapi-fhir-jpaserver-starter/target/*.war /usr/local/tomcat/webapps/

RUN apt-get update && apt-get install gettext-base -y

# MySQL Database Connection Settings
ARG MYSQL_HOST=127.0.0.1
ARG MYSQL_PORT=3306
ARG MYSQL_DATABASE=hapi_fhir
ARG MYSQL_USER=root
ARG MYSQL_PASSWORD=secret

ENV MYSQL_HOST=$MYSQL_HOST
ENV MYSQL_PORT=$MYSQL_PORT
ENV MYSQL_DATABASE=$MYSQL_DATABASE
ENV MYSQL_USER=$MYSQL_USER
ENV MYSQL_PASSWORD=$MYSQL_PASSWORD

# Other environment variables
ARG FHIR_VERSION=R4
ARG JAVA_OPTS=-Dhapi.properties=/config/hapi.properties

ENV JAVA_OPTS=$JAVA_OPTS
ENV FHIR_VERSION=$FHIR_VERSION

COPY ./server.xml  /tmp/server.xml

RUN mkdir /config
COPY ./hapi.properties  /tmp/hapi.properties.tpl

EXPOSE 8080

CMD envsubst < /tmp/hapi.properties.tpl > /config/hapi.properties && catalina.sh run
