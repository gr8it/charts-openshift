# --- Stage 1: Plugin Downloader ---
FROM confluentinc/cp-kafka-connect:8.1.0 AS builder
# FROM confluentinc/cp-kafka-connect:7.6.0 AS builder

# 1. Install S3 Connector (Standard Version)
# RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:11.0.8 \
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.6.8 \
    --component-dir /usr/share/confluent-hub-components

# 2. Install Avro Converter (The "Good" Version - 7.6.0)
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-avro-converter:7.6.8 \
    --component-dir /usr/share/confluent-hub-components

# USER 1001
# WORKDIR /opt/kafka

    # --- Stage 2: Final Image & Jar Surgery ---
FROM quay.io/strimzi/kafka:latest-kafka-4.0.1-amd64

USER root:root
WORKDIR /opt/kafka

# Create plugins directory
RUN mkdir -p /opt/kafka/plugins

# Copy plugins from builder
COPY --from=builder /usr/share/confluent-hub-components/ /opt/kafka/plugins/

# === THE CRITICAL FIX ===
# 1. Enter the S3 connector directory

# 2. DELETE the bundled versions that are causing conflicts (7.7.5/etc)
#    We remove avro-data, schema-registry-client, and common-config to prevent shadowing.
# RUN rm /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/kafka-connect-avro-*.jar \
#        /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/kafka-schema-*.jar \
#        /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/kafka-avro-serializer-*.jar \
#        /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/common-utils-*.jar || true

# # 3. COPY the "Good" versions (7.6.0) from the Avro Converter plugin
# #    This forces S3 connector to use the exact same libraries as the Converter.
# RUN cp /opt/kafka/plugins/confluentinc-kafka-connect-avro-converter/lib/kafka-connect-avro-*.jar /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/ && \
#     cp /opt/kafka/plugins/confluentinc-kafka-connect-avro-converter/lib/kafka-schema-*.jar /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/ && \
#     cp /opt/kafka/plugins/confluentinc-kafka-connect-avro-converter/lib/kafka-avro-serializer-*.jar /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/ && \
#     cp /opt/kafka/plugins/confluentinc-kafka-connect-avro-converter/lib/common-utils-*.jar /opt/kafka/plugins/confluentinc-kafka-connect-s3/lib/

# Switch back to Strimzi user
USER 1001
WORKDIR /opt/kafka
