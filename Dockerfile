FROM sonarqube:7.7-community
USER root
RUN apt-get update \
  && apt-get install -y pylint jq\
  && rm -rf /var/lib/apt/lists/*
ADD ./plugins /tmp/plugins
RUN rm -rf ./extensions/plugins/* && \
    cat /tmp/plugins/plugin-list && \
    chmod +x /tmp/plugins/install-plugins.sh && \
    ls /tmp/plugins -l && \
    /tmp/plugins/install-plugins.sh
WORKDIR /opt/sonarqube
COPY ./start-with-profile.sh .
ADD ./rules /tmp/rules
ADD sonar.properties /opt/sonarqube/conf/sonar.properties
RUN chown -R sonarqube:sonarqube . && chmod +x start-with-profile.sh
USER sonarqube
CMD ["./start-with-profile.sh"]
