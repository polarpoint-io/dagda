# build stage
FROM python:3.6.4-alpine3.6
MAINTAINER "Polarpoint.io <surj@polarpoint.io>"

# Docker CLI
ARG DOCKER_CLI_VERSION="17.06.2-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

# install docker client
RUN apk --update add curl \
    && mkdir -p /tmp/download \
    && curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download \
    && mv /tmp/download/docker/docker /usr/local/bin/ \
    && rm -rf /tmp/download \
    && apk del curl \
    && rm -rf /var/cache/apk/*


COPY requirements.txt /opt/app/requirements.txt

# add user and group 
ARG user=dagda
ARG group=dagda
ARG uid=1000
ARG gid=1000

ARG groupd=docker
ARG gidd=117
RUN addgroup -g ${gidd} ${groupd}

ENV HOME /home/${user}
RUN addgroup -g ${gid} ${group}
RUN adduser -h $HOME -u ${uid} -G ${group} -D ${user}
RUN adduser ${user} ${groupd}
RUN rm -rf /var/lib/apt/lists/*

USER ${user}

WORKDIR /opt/app
RUN  pip install -r requirements.txt --user

COPY dagda  /opt/app
ENTRYPOINT [ "sh", "-c", "python dagda.py start -s $SERVER_HOST  -p $SERVER_PORT  -m $MONGODB_HOST -mp $MONGODB_PORT  --mongodb_user $MONGODB_USER --mongodb_pass $MONGODB_PASS " ]
