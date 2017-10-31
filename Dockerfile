FROM sonarqube:6.6-alpine
RUN apk update && apk add bash unzip

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

ADD ./plugins /tmp/plugins
RUN chmod +x /tmp/plugins/install-plugins.sh
RUN ls /tmp/plugins -l
RUN /tmp/plugins/install-plugins.sh

ADD ./profiles /tmp/profiles
RUN ls /tmp/profiles -l
RUN mv /tmp/profiles/start-with-profile.sh /opt/sonarqube/start-with-profile.sh
RUN ls /opt/sonarqube -l

WORKDIR /opt/sonarqube
RUN chmod +x start-with-profile.sh

CMD ["./start-with-profile.sh"]