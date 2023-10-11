FROM public.ecr.aws/x5l4h1c0/app:java
VOLUME /tmp
ARG JAR_FILE=*.jar
COPY $JAR_FILE app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
