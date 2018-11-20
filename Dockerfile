FROM sonarqube:7.1-alpine
RUN apk update && apk add bash unzip

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

ADD ./plugins /tmp/plugins
RUN cat /tmp/plugins/plugin-list && \
    chmod +x /tmp/plugins/install-plugins.sh && \
    ls /tmp/plugins -l && \
    /tmp/plugins/install-plugins.sh

WORKDIR /opt/sonarqube
COPY ./start-with-profile.sh .
RUN chmod +x start-with-profile.sh

ADD ./rules /tmp/rules
ADD sonar.properties /opt/sonarqube/conf/sonar.properties

CMD ["./start-with-profile.sh"]
