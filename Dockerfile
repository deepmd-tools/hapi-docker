# Stage 1: Build HAPI FHIR from source
FROM tomcat:9-jre11 as build-hapi

# Arguments for cloning specific branches or versions
ARG HAPI_FHIR_URL=https://github.com/hapifhir/hapi-fhir/
ARG HAPI_FHIR_BRANCH=v5.0.0
ARG HAPI_FHIR_STARTER_URL=https://github.com/hapifhir/hapi-fhir-jpaserver-starter/
ARG HAPI_FHIR_STARTER_BRANCH=master

# Install necessary packages for building
RUN apt-get update && apt-get install -y maven git

# Clone the HAPI FHIR repository
RUN git clone --branch ${HAPI_FHIR_BRANCH} ${HAPI_FHIR_URL} /tmp/hapi-fhir
WORKDIR /tmp/hapi-fhir

# Resolve dependencies and install HAPI FHIR
RUN mvn dependency:resolve
RUN mvn install -DskipTests

# Clone the HAPI FHIR JPA Server Starter repository
RUN git clone --branch ${HAPI_FHIR_STARTER_BRANCH} ${HAPI_FHIR_STARTER_URL} /tmp/hapi-fhir-jpaserver-starter
WORKDIR /tmp/hapi-fhir-jpaserver-starter

# Build the HAPI FHIR JPA Server Starter project
RUN mvn clean install -DskipTests

# Stage 2: Deploy the built HAPI FHIR server
FROM tomcat:9-jre11

# Create directories for HAPI FHIR data and logs
RUN mkdir -p /data/hapi/lucenefiles && chmod 775 /data/hapi/lucenefiles

# Copy the WAR file from the build stage to the Tomcat webapps directory
COPY --from=build-hapi /tmp/hapi-fhir-jpaserver-starter/target/*.war /usr/local/tomcat/webapps/

# Optionally, copy configuration files if needed
# COPY ./your-hapi-config-files /path/in/container

# Expose the Tomcat server port
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
