FROM public.ecr.aws/x6e3i3q9/app:java
VOLUME /tmp
ARG JAR_FILE=*.jar
COPY $JAR_FILE app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
