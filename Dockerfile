FROM alpine:latest
COPY entrypoint.sh /entrypoint.sh
RUN  apk update \
    && apk add curl \
    && chmod +x entrypoint.sh 
ENTRYPOINT ["/bin/ash","entrypoint.sh"]
