# Multi-stage build for minimal image size
# Stage 1: Build
FROM gradle:8.5-jdk21-alpine AS builder

WORKDIR /app

# Copy Gradle files first (for caching)
COPY build.gradle ./
COPY gradle ./gradle
COPY gradlew ./

# Download dependencies (cached layer)
RUN ./gradlew dependencies --no-daemon || return 0

# Copy source code
COPY src ./src

# Build application (skip tests for faster build)
RUN ./gradlew clean build -x test --no-daemon

# Stage 2: Runtime
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy JAR from builder stage
COPY --from=builder /app/build/libs/backend-1.0.0.jar app.jar

# Expose port (Render provides $PORT)
EXPOSE 8080

# Memory-optimized JVM options for 512MB RAM
ENV JAVA_OPTS="-Xms48m -Xmx180m -Xss256k \
    -XX:+UseSerialGC \
    -XX:MaxMetaspaceSize=56m \
    -XX:ReservedCodeCacheSize=12m \
    -XX:MaxDirectMemorySize=10m \
    -XX:+TieredCompilation \
    -XX:TieredStopAtLevel=1 \
    -XX:+UseStringDeduplication \
    -XX:+UseCompressedOops \
    -XX:+UseCompressedClassPointers \
    -XX:CompressedClassSpaceSize=24m \
    -XX:MinHeapFreeRatio=10 \
    -XX:MaxHeapFreeRatio=20 \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.jmx.enabled=false"

# Run application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -Dspring.profiles.active=prod -jar app.jar"]
