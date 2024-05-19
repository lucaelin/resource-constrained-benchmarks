# Use official GraalVM image for the builder stage
FROM ghcr.io/graalvm/native-image-community:21-ol9 as builder

WORKDIR /app

RUN microdnf install maven --setopt=install_weak_deps=0

# Copy pom.xml and get all dependencies
COPY pom.xml ./
RUN mvn dependency:go-offline

# Copy source code and build the application
COPY ./src ./src
RUN mvn package -Pnative -DskipTests


# For the runner stage use a distroless image
FROM ghcr.io/graalvm/jdk-community:21-ol9

WORKDIR /app

# Copy the native binary from the builder stage
COPY --from=builder /app/target/* .

EXPOSE 8080

ENTRYPOINT ["/app/apples"]