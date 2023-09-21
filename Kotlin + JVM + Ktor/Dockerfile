# Use the official Kotlin image as the base image
FROM openjdk:19-jdk-slim as builder

WORKDIR /app

# Copy the local gradle.properties, build.gradle.kts and settings.gradle.kts to the container
COPY gradle.properties build.gradle.kts settings.gradle.kts ./
COPY gradle gradle
COPY gradlew gradlew
RUN chmod +x gradlew

# Copy the src directory from the host to the container
COPY src src

# Build the project in the container
RUN ./gradlew clean build

# Multi-stage build: Use a smaller base image for the final image
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy only the built jar and any other necessary files from builder to the current stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Set the necessary flags and entry point for your application
ENTRYPOINT ["java", "-jar", "app.jar"]