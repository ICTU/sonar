ARG IMAGE_NAME=sonarqube
ARG IMAGE_VERSION=10.3.0
ARG IMAGE_EDITION=community

FROM $IMAGE_NAME:$IMAGE_VERSION-$IMAGE_EDITION

LABEL org.opencontainers.image.authors="open-source-projects@ictu.nl"
LABEL org.opencontainers.image.url="https://github.com/ICTU/sonar"
LABEL org.opencontainers.image.documentation="https://raw.githubusercontent.com/ICTU/sonar/master/README.md"
LABEL org.opencontainers.image.source="https://raw.githubusercontent.com/ICTU/sonar/master/Dockerfile"
LABEL org.opencontainers.image.vendor="ICTU"
LABEL org.opencontainers.image.title="ICTU SonarQube"
LABEL org.opencontainers.image.description="A SonarQube container image with plugins, profiles and config used at ICTU"

USER root

RUN apt-get update \
    && apt-get install -y wget curl ca-certificates-java jq postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY ./plugins /tmp/plugins
RUN rm -rf ./extensions/plugins/* && \
    cat /tmp/plugins/plugin-list && \
    chmod +x /tmp/plugins/install-plugins.sh && \
    /tmp/plugins/install-plugins.sh

WORKDIR /opt/sonarqube

COPY ./start-with-profile.sh .
COPY ./rules /tmp/rules
COPY sonar.properties /opt/sonarqube/conf/sonar.properties

RUN chown -R sonarqube:sonarqube . \
    && chmod +x start-with-profile.sh

USER sonarqube

CMD ["./start-with-profile.sh"]
