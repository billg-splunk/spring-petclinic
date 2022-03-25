FROM adoptopenjdk/openjdk11:jre-11.0.14.1_1-alpine
EXPOSE 8080
ARG JAR=spring-petclinic-2.4.5.jar
COPY target/$JAR /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
