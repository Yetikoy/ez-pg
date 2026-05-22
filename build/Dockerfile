FROM postgres:18

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Just
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# Install WAL-G
RUN wget https://github.com/wal-g/wal-g/releases/download/v3.0.8/wal-g-pg-24.04-amd64.tar.gz \
    && tar -zxvf wal-g-pg-24.04-amd64.tar.gz \
    && mv wal-g-pg-24.04-amd64 /usr/local/bin/wal-g \
    && rm wal-g-pg-24.04-amd64.tar.gz

COPY init.sh /docker-entrypoint-initdb.d/postgres-init.sh
COPY justfile /justfile

# We stay as root for the entrypoint so just can manage env/setup, 
# but postgres will be dropped to 'postgres' user by the official script.
ENTRYPOINT ["just", "-f", "/justfile"]
CMD ["run"]
