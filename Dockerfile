FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN groupadd security && useradd -G security pipeline
COPY ${JAR_FILE} /home/pipeline/app.jar
USER pipeline
ENTRYPOINT ["java","-jar","/home/pipeline/app.jar"]
