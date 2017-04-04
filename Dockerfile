FROM sonarqube:5.6.6

ADD ./plugins /tmp/plugins

RUN /tmp/plugins/install-plugins.sh
