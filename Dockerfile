FROM mysql:5.7.12

RUN useradd -r backupper

USER backupper

COPY entrypoint.sh /tmp

ENTRYPOINT ["/tmp/entrypoint.sh"]
