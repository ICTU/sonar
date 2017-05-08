FROM sonarqube:6.3.1

ADD ./plugins /tmp/plugins

RUN /tmp/plugins/install-plugins.sh
