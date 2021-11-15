#! /bin/sh

set -eu
set -o pipefail

export DATABASE_NAME="${DATABASE_URL##*/}"

echo "Creating backup of $DATABASE_NAME database..."
pg_dump --format=custom -d $DATABASE_URL > db.dump

s3_uri_base="s3://${S3_BUCKET}/${DATABASE_NAME}.dump"

echo "Encrypting backup..."
gpg --symmetric --batch --passphrase "$PASSPHRASE" db.dump
rm db.dump
local_file="db.dump.gpg"
s3_uri="${s3_uri_base}.gpg"

echo "Uploading backup to $AWS_S3_BUCKET..."
aws s3 cp "$local_file" "$s3_uri"
rm "$local_file"

echo "Backup complete."
