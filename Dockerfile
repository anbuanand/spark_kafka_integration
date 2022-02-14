# Base image to start from.
FROM ubuntu:20.04



# Information surrounding the creator.
LABEL maintainer="boswesley@live.nl"
LABEL version="0.1"
LABEL description="Docker image to setp up Apache Spark standalone."

# Update the system.
RUN apt-get update \ 
 && apt-get install -qq -y curl vim net-tools \
 && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update \
 && apt-get install -y python3 \ 
 && ln -s /usr/bin/python3 /usr/bin/python \
 && rm -rf /var/lib/apt/lists/*

# Install Java
RUN apt-get update \
 && apt-get install -y openjdk-11-jre \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Spark
RUN apt-get update -y \
 && apt-get install -y curl \
 && curl https://archive.apache.org/dist/spark/spark-3.2.1/spark-3.2.1-bin-hadoop2.7.tgz -o spark.tgz \
 && tar -xf spark.tgz \
 && mv spark-3.2.1-bin-hadoop2.7 /opt/spark/ \
 && rm spark.tgz

# Install extra jars for Spark to Kafka integration
RUN rm -rf dir/tmp \
    && mkdir -p dir/tmp/jars \
    && echo "Downloading spark-kafka integration jars" \
    && curl "https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.0/commons-pool2-2.11.0.jar" -o dir/tmp/jars/commons-pool2-2.11.1.jar \
    && curl "https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.1.0/kafka-clients-3.1.0.jar" -o dir/tmp/jars/kafka-clients-3.1.0.jar \
    && curl "https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.2.1/spark-sql-kafka-0-10_2.12-3.2.1.jar" -o dir/tmp/jars/spark-sql-kafka-0-10_2.12-3.2.1.jar \
    && curl "https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.12/3.2.1/spark-token-provider-kafka-0-10_2.12-3.2.1.jar" -o dir/tmp/jars/spark-token-provider-kafka-0-10_2.12-3.2.1.jar \
    && mv  dir/tmp/jars/*.jar /opt/spark/jars \
    && echo "Done Downloading all the required spark and kafka integration jars"

# Set Spark environment
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

# EXPOSE CONTAINER PORTS
EXPOSE 4040 6066 7077 8080

# SET WORKING DIR
WORKDIR $SPARK_HOME

# Copy files
COPY log4j.properties $SPARK_HOME/conf
COPY supplementary_files $SPARK_HOME/supplementary_files
COPY python_code_samples $SPARK_HOME/python_code_samples

# Run commands
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master", "org.apache.spark.deploy.worker.Worker"]
