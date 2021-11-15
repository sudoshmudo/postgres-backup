FROM alpine:3.12

ADD src/install.sh install.sh
RUN sh install.sh && rm install.sh

ADD src/run.sh run.sh
ADD src/backup.sh backup.sh
ADD src/restore.sh restore.sh

CMD ["sh", "run.sh"]
