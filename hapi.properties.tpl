# FHIR Server Configuration
fhir_version=${FHIR_VERSION}

# Server Address
server_address=http://${HOST}:${PORT}/hapi-fhir-jpaserver/fhir/

# MySQL Database Connection Settings
datasource.driver=com.mysql.cj.jdbc.Driver
datasource.url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}?useSSL=false&serverTimezone=UTC
datasource.username=${MYSQL_USER}
datasource.password=${MYSQL_PASSWORD}
hibernate.dialect=org.hibernate.dialect.MySQLDialect

# Hibernate Configuration
hibernate.format_sql=false
hibernate.show_sql=false
hibernate.hbm2ddl.auto=update
hibernate.jdbc.batch_size=20
hibernate.cache.use_query_cache=false
hibernate.cache.use_second_level_cache=false
hibernate.cache.use_structured_entries=false
hibernate.cache.use_minimal_puts=false
hibernate.search.default.directory_provider=filesystem
hibernate.search.default.indexBase=target/lucenefiles
hibernate.search.lucene_version=LUCENE_CURRENT

# Other configuration settings as needed...
