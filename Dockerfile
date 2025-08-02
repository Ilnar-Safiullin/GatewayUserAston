# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

# Environment variables
ENV SPRING_PROFILES_ACTIVE=docker \
    SPRING_CONFIG_IMPORT=configserver:http://config-server:8888 \
    EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://discovery-service:8761/eureka \
    SPRING_CLOUD_GATEWAY_DISCOVERY_LOCATOR_ENABLED=true

EXPOSE 8082
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8082/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]