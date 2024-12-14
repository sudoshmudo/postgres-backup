FROM postgres:17.2-alpine

RUN apk add --update php py-pip mysql-client \
    && apk add pipx \
    && pipx install awscli \
    && rm -rf /var/cache/apk/*

ADD src/install.sh install.sh
RUN sh install.sh && rm install.sh

ADD src/run.sh run.sh
ADD src/backup.sh backup.sh
ADD src/restore.sh restore.sh

CMD ["sh", "run.sh"]
