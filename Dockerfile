FROM sonarqube:5.6.4

ADD ./plugins /tmp/plugins

RUN /tmp/plugins/install-plugins.sh
