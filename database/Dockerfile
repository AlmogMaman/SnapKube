# Use the official PostgreSQL image as a base
FROM postgres:14

# Set the working directory
WORKDIR /docker-entrypoint-initdb.d

# Copy your SQL dump file into the container
COPY init.sql /docker-entrypoint-initdb.d/
