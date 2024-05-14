# Use official GraalVM image for the builder stage
FROM vegardit/graalvm-maven:22.3.2-java17 as builder

WORKDIR /app

# Copy pom.xml and get all dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline

# Copy source code and build the application
COPY ./src ./src
RUN mvn package -Dpackaging=native-image -DskipTests


# For the runner stage use a distroless image
FROM ghcr.io/graalvm/jdk-community:21-ol9

WORKDIR /app

# Copy the native binary from the builder stage
COPY --from=builder /app/target/* .

EXPOSE 8080

ENTRYPOINT ["/app/apples"]