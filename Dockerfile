FROM sonarqube:6.4-alpine

RUN apk update && apk add bash unzip

ADD ./plugins /tmp/plugins

RUN /tmp/plugins/install-plugins.sh
