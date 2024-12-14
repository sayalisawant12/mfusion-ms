# Stage 1: Build image with Java 17
FROM openjdk:17-jdk-slim AS builder

# Install dependencies for building the application if necessary
WORKDIR /app
COPY ./target/mfusion-ms.jar /app/

# Stage 2: Use Tomcat as the base image
FROM tomcat:9.0.52-jre11-openjdk-slim

# Install Java 17
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get clean;

# Set Java 17 as the default Java version
RUN update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Add the JAR file from the builder stage to the Tomcat webapps directory
COPY --from=builder /app/mfusion-ms.jar /usr/local/tomcat/webapps/

# Expose port 8080
EXPOSE 8080

# Add user 'fusion' and set it as the container user
RUN useradd -ms /bin/bash fusion
USER fusion

# Set the working directory
WORKDIR /usr/local/tomcat/webapps

# Start Tomcat
CMD ["catalina.sh", "run"]
