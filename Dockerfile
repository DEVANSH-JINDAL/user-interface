# Stage 1: Build React frontend
FROM node:18-alpine AS frontend-build
WORKDIR	/app
COPY src/main/frontend/package*.json ./
RUN npm install
COPY src/main/frontend/ ./
RUN npm run build

#Stage 2: Build Spring Boot backend
FROM maven:3.9.6-eclipse-temurin-17-alpine AS backend-build
WORKDIR /build
COPY pom.xml ./
COPY src ./src
COPY --from=frontend-build /app/build ./src/main/resources/static
RUN mvn clean package -DskipTests

# Stage 3: Run the App
FROM eclipse-temurin:17-alpine
WORKDIR /opt/application
COPY --from=backend-build /build/target/*.jar web.jar
EXPOSE 8080
ENTRYPOINT ["java", "-XshowSettings:vm", "-jar", "web.jar"]
