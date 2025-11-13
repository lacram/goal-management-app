# Multi-stage build for minimal image size
# Stage 1: Build
FROM gradle:8.5-jdk21-alpine AS builder

WORKDIR /app

# Copy all project files
COPY . .

# Make gradlew executable (fix permission issue)
RUN chmod +x gradlew || true

# Build using gradle command directly (more reliable than gradlew in Docker)
RUN gradle clean build -x test --no-daemon --stacktrace

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy JAR from builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Expose port (Render provides $PORT)
EXPOSE 8080

# Memory-optimized JVM options for Render 512MB RAM
ENV JAVA_OPTS="-Xms64m -Xmx256m -Xss512k \
    -XX:+UseSerialGC \
    -XX:MaxMetaspaceSize=128m \
    -XX:ReservedCodeCacheSize=32m \
    -XX:MaxDirectMemorySize=10m \
    -XX:+UseCompressedOops \
    -XX:+UseCompressedClassPointers \
    -XX:MinHeapFreeRatio=10 \
    -XX:MaxHeapFreeRatio=20 \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.jmx.enabled=false"

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -Dspring.profiles.active=prod -jar app.jar"]
