FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

# Copy pre-built JAR (build locally first)
COPY build/libs/*.jar app.jar

EXPOSE 8888

ENTRYPOINT ["java", "-jar", "app.jar"]
