FROM gradle:4.5-jdk8-alpine as builder
# Create and choose a workdir
RUN mkdir /home/gradle/project
WORKDIR /home/gradle/project
# Copy pom.xml to get dependencies
COPY build.gradle settings.gradle ./
# This will resolve dependencies and cache them
RUN gradle build
# Copy sources
COPY src src
# Build app (jar will be in /usr/src/app/target/)
RUN gradle build

FROM openjdk:8-jre-alpine
WORKDIR /opt/app
# Copy bin from builder to this new image
COPY --from=builder /home/gradle/project/build/libs/docker-multi-stage-build.jar docker-multi-stage-build.jar
# Default command, run app
CMD java -jar docker-multi-stage-build.jar