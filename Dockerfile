ARG IMAGE_NAME=sonarqube
ARG IMAGE_VERSION=2025.4.2
ARG IMAGE_EDITION=developer

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

COPY ./src /src
RUN mv /src/sonar.properties /opt/sonarqube/conf/sonar.properties && \
    chmod +x /src/ /src/*.sh && \
    rm -rf ./extensions/plugins/* && \
    /src/install-plugins.sh

WORKDIR /opt/sonarqube
RUN chown -R sonarqube .

USER sonarqube

HEALTHCHECK --start-period=5m CMD /src/health-check.sh

CMD ["/src/start-with-profile.sh"]
