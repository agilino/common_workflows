# This Dockerfile is used in order to build a container that runs our spring app
FROM openjdk:16-alpine
ARG RUN_JAVA_VERSION=1.3.8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

# install curl in alpine image
RUN apk add --update curl && rm -rf /var/cache/apk/*

# use run file from fabric8
RUN mkdir /deployments
RUN chown 1001 /deployments
RUN chmod "g+rwX" /deployments
RUN chown 1001:root /deployments
RUN curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh
RUN chown 1001 /deployments/run-java.sh
RUN chmod 540 /deployments/run-java.sh

# run by default in spring dev profile
ENV JAVA_OPTIONS="-Dspring.profiles.active=dev"

COPY backend/build/libs/*.jar /deployments/app.jar

EXPOSE 8180

ENTRYPOINT [ "/deployments/run-java.sh" ]
