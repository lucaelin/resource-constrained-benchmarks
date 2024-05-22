# Use official Maven image for the builder stage
FROM maven:3.9-amazoncorretto-21-debian as builder

WORKDIR /app

# Copy pom.xml and get all dependencies
COPY pom.xml ./
RUN --mount=type=cache,target=/app/.m2 mvn dependency:go-offline -Dmaven.repo.local=/app/.m2

# Copy source code and build the application
COPY ./src ./src
RUN mvn package -DskipTests


# For the runner stage use openjdk image
FROM amazoncorretto:21-alpine3.19-jdk

WORKDIR /app

# Copy the jar file from the builder stage
COPY --from=builder /app/target/*.jar ./app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
