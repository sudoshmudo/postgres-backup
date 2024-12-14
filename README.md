# Introduction
This project provides Docker images to periodically back up a PostgreSQL database to AWS S3, and to restore from the backup as needed.
Logs are intentionally surpressed to avoid log pollution.

# Usage
## Backup
```yaml
postgres:
  image: postgres:12
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password

  postgres-backup:
    image: ghcr.io/sudoshmudo/postgres-backup:latest
    environment:
      - DATABASE_URL
      - PASSPHRASE
      - AWS_ACCESS_KEY_ID
      - AWS_DEFAULT_REGION
      - AWS_S3_BUCKET
      - AWS_SECRET_ACCESS_KEY
      - SCHEDULE
    depends_on:
      - postgres
```
- Image is built for version `12`.
- Suitable for Raspberry and ARM architecture.
- The `SCHEDULE` variable determines backup frequency. See go-cron schedules documentation [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).
- `DATABASE_URL` is in format: postgresql://username:password@postgres:5432/database_name
- `PASSPHRASE` is used to encrypt file using GPG.
- Run `docker exec <container name> sh backup.sh` to trigger a backup ad-hoc
- All of the variables in the example must be defined
- Filename is in format: database_name.gpg (it gets overwritten each time)
- It is highly recommended to set versioning on the bucket

## Restore
> **WARNING:** DATA LOSS! All database objects will be dropped and re-created.
### ... from latest backup
```sh
docker exec <container name> sh restore.sh
```
> **NOTE:** If your bucket has more than a 1000 files, the latest may not be restored -- only one S3 `ls` command is used
### ... from specific backup
```sh
docker exec <container name> sh restore.sh <timestamp>
```

## Testing and development

```sh
docker compose build && docker compose up --force-recreate
```

# Acknowledgements
This project is a fork of [postgres-backup-s3](https://github.com/eeshugerman/postgres-backup-s3).
