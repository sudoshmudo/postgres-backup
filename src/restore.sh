#! /bin/sh

set -u
set -o pipefail

export DATABASE_NAME="${DATABASE_URL##*/}"

s3_uri_base="s3://${AWS_S3_BUCKET}"
file_type=".dump.gpg"
key_suffix="${DATABASE_NAME}${file_type}"

echo "Fetching backup from S3..."
aws s3 cp "${s3_uri_base}/${key_suffix}" "db${file_type}"

echo "Decrypting backup..."
gpg --decrypt --batch --passphrase "$PASSPHRASE" db.dump.gpg > db.dump
rm db.dump.gpg

conn_opts="-d $DATABASE_URL"

echo "Restoring from backup..."
pg_restore $conn_opts --clean --if-exists db.dump
rm db.dump

echo "Restore complete."
