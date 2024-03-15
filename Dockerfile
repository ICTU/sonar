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

COPY sonar.properties /opt/sonarqube/conf/sonar.properties
COPY ./src /src
RUN chmod +x /src/ /src/*.sh && \
    rm -rf ./extensions/plugins/* && \
    /src/install-plugins.sh

WORKDIR /opt/sonarqube
RUN chown -R sonarqube:sonarqube .

USER sonarqube

CMD ["/src/start-with-profile.sh"]
