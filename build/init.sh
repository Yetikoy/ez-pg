#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# This script is executed by the Postgres image upon first run.
# It initializes databases specified in POSTGRES_MULTIPLE_DBS.

# Check if POSTGRES_MULTIPLE_DBS is set
if [ -z "$POSTGRES_MULTIPLE_DBS" ]; then
  echo "No databases specified for creation in POSTGRES_MULTIPLE_DBS."
  exit 0
fi

# Split the comma-separated list into an array
IFS=',' read -ra DB_NAMES <<< "$POSTGRES_MULTIPLE_DBS"

# Loop through each database name
for DB_NAME in "${DB_NAMES[@]}"; do
  # Clean up database name (e.g., remove whitespace)
  CLEAN_DB_NAME=$(echo "$DB_NAME" | xargs)
  
  if [ -z "$CLEAN_DB_NAME" ]; then
    continue
  fi

  echo "Processing database: $CLEAN_DB_NAME"
  
  # Construct the environment variable name for the password
  # e.g., for db 'keycloak', we look for POSTGRES_KEYCLOAK_PASSWORD
  PASSWORD_ENV_VAR="POSTGRES_${CLEAN_DB_NAME^^}_PASSWORD"
  
  # Get the password from environment variables
  DB_PASSWORD="${!PASSWORD_ENV_VAR}" # Bash indirect expansion

  if [ -z "$DB_PASSWORD" ]; then
    echo "Warning: Password environment variable '$PASSWORD_ENV_VAR' not set for database '$CLEAN_DB_NAME'. Skipping."
    continue
  fi

  # Create the database and user
  # Use psql command with the POSTGRES_USER and POSTGRES_PASSWORD from the .env file
  # These are always available when the postgres image starts.
  echo "Creating database '$CLEAN_DB_NAME' and user '$CLEAN_DB_NAME' with password."
  
  # Use psql to run SQL commands. '\l' lists databases, '\du' lists users.
  # We need to be careful with quoting and ensuring the user exists with permissions.
  # A common pattern is to create the user first, then the database owned by that user.
  
  # Create the user
  # We use `ALTER SYSTEM SET ...` for better handling of password changes if the user exists,
  # but direct creation is safer for first run.
  # Note: We assume the DB name and user name are the same for simplicity.
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
      CREATE USER "$CLEAN_DB_NAME" WITH PASSWORD '$DB_PASSWORD';
      CREATE DATABASE "$CLEAN_DB_NAME" OWNER "$CLEAN_DB_NAME";
      GRANT ALL PRIVILEGES ON DATABASE "$CLEAN_DB_NAME" TO "$CLEAN_DB_NAME";
EOSQL
  
done

echo "Database initialization script finished."

