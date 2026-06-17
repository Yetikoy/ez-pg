FROM tensorchord/vchord-scratch:pg18-v1.1.1 AS vchord_scratch
FROM postgis/postgis:18-3.6

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

# Install pg extensions
COPY --from=vchord_scratch / /
RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && apt-get update && apt-get install -y \
    postgresql-18-cron \
    postgresql-18-auto-failover \
    postgresql-18-documentdb \
    postgresql-18-first-last-agg \
    postgresql-18-h3 \
    postgresql-18-hll \
    postgresql-18-partman \
    postgresql-18-pgq3 \
    postgresql-18-pgpcre \
    postgresql-18-pgvector \
    postgresql-18-semver \
    postgresql-18-timescaledb \
    postgresql-18-unit \
&& rm -rf /var/lib/apt/lists/*
# TODO: process above installs A LOT of stuff, not just the extensions (which are small). Thin it out?
# TODO: set up auto-failover with another nodes on same s3


COPY justfile /justfile

# We stay as root for the entrypoint so just can manage env/setup, 
# but postgres will be dropped to 'postgres' user by the official script.
ENTRYPOINT ["just", "-f", "/justfile"]
CMD ["run"]
