# Use official Maven image for the builder stage
FROM maven:3.8.2-openjdk-17-slim as builder

WORKDIR /app

# Copy pom.xml and get all dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline

# Copy source code and build the application
COPY ./src ./src
RUN mvn package -DskipTests



# For the runner stage use openjdk image
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the jar file from the builder stage
COPY --from=builder /app/target/*.jar ./app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
