#! /bin/sh

set -u
set -o pipefail

if [ -z "$S3_ACCESS_KEY_ID" ]; then
  echo "You need to set the S3_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ -z "$S3_SECRET_ACCESS_KEY" ]; then
  echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ -z "$S3_BUCKET" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

if [ -z "$DATABASE_URL" ]; then
  echo "You need to set the DATABASE_URL environment variable."
  exit 1
fi

export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$S3_REGION
export DATABASE_NAME="${DATABASE_URL##*/}"

s3_uri_base="s3://${S3_BUCKET}"

if [ -z "$PASSPHRASE" ]; then
  file_type=".dump"
else
  file_type=".dump.gpg"
fi

if [ $# -eq 1 ]; then
  key_suffix="${DATABASE_NAME}${file_type}"
else
  echo "Finding latest backup..."
  key_suffix=$(
    aws s3 ls "${s3_uri_base}/${DATABASE_NAME}" \
      | sort \
      | tail -n 1 \
      | awk '{ print $4 }'
  )
fi

echo "Fetching backup from S3..."
aws s3 cp "${s3_uri_base}/${key_suffix}" "db${file_type}"

if [ -n "$PASSPHRASE" ]; then
  echo "Decrypting backup..."
  gpg --decrypt --batch --passphrase "$PASSPHRASE" db.dump.gpg > db.dump
  rm db.dump.gpg
fi

conn_opts="-d $DATABASE_URL"

echo "Restoring from backup..."
pg_restore $conn_opts --clean --if-exists db.dump
rm db.dump

echo "Restore complete."
