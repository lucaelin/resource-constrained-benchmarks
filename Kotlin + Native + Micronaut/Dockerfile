# Use official GraalVM image for the builder stage
FROM ghcr.io/graalvm/native-image-community:21-ol9 as builder

WORKDIR /app

RUN microdnf install maven

# Copy pom.xml and get all dependencies
COPY pom.xml ./
RUN --mount=type=cache,target=/app/.m2 mvn -Dmaven.repo.local=/app/.m2 dependency:go-offline

# Copy source code and build the application
COPY ./src ./src
RUN --mount=type=cache,target=/app/.m2 mvn -Dmaven.repo.local=/app/.m2 package -Dpackaging=native-image -DskipTests


# For the runner stage use a distroless image
FROM ghcr.io/graalvm/jdk-community:21-ol9

WORKDIR /app

# Copy the native binary from the builder stage
COPY --from=builder /app/target/* .

EXPOSE 8080

ENTRYPOINT ["/app/apples"]