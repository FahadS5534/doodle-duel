# ==========================================
# Render / Cloud Production Dockerfile
# ==========================================

# 1. Build Stage
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /app

# Cache Maven dependencies
COPY backend/pom.xml .
RUN mvn dependency:go-offline -B

# Copy backend source code and build executable jar
COPY backend/src ./src
RUN mvn clean package -DskipTests

# 2. Runtime Stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Install utilities
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -S doodle && adduser -S doodle -G doodle
USER doodle

# Copy fat jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

# Execute with dynamic PORT environment variable support
ENTRYPOINT ["sh", "-c", "exec java -Djava.security.egd=file:/dev/./urandom -Dserver.port=${PORT:-8080} -jar app.jar"]
