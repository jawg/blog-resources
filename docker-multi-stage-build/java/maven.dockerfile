FROM maven:3.5-jdk-8-alpine as builder
# Choose a workdir
WORKDIR /usr/src/app
# Copy pom.xml to get dependencies
COPY pom.xml .
# This will resolve dependencies and cache them
RUN mvn package && rm -r target
# Copy sources
COPY src src
# Build app (jar will be in /usr/src/app/target/)
RUN mvn package

FROM openjdk:8-jre-alpine
WORKDIR /opt/app
# Copy bin from builder to this new image
COPY --from=builder /usr/src/app/target/docker-multi-stage-build-1.0.0-jar-with-dependencies.jar docker-multi-stage-build.jar
# Default command, run app
CMD java -jar docker-multi-stage-build.jar