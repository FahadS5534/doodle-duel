# ==========================================
# Backend Subdirectory Dockerfile
# ==========================================

# 1. Build Stage
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build jar
COPY src ./src
RUN mvn clean package -DskipTests

# 2. Runtime Stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Install utilities
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -S doodle && adduser -S doodle -G doodle
USER doodle

# Copy jar artifact from build stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

# Execute with dynamic PORT environment variable support
ENTRYPOINT ["sh", "-c", "exec java -Djava.security.egd=file:/dev/./urandom -Dserver.port=${PORT:-8080} -jar app.jar"]
