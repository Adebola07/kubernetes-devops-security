FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup -S pipelines && adduser -S pipeline -G pipelines
COPY ${JAR_FILE} /home/pipeline/app.jar
USER pipeline
ENTRYPOINT ["java","-jar","/home/pipeline/app.jar"]


