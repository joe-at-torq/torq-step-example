FROM alpine:3.17.3
COPY entrypoint.sh /entrypoint.sh
RUN  apk update \
    && apk add curl \
    && chmod +x entrypoint.sh 
ENTRYPOINT ["/bin/ash","entrypoint.sh"]
