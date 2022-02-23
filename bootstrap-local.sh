#!/usr/bin/env bash
export OTEL_SERVICE_NAME='petclinic'
export OTEL_RESOURCE_ATTRIBUTES='deployment.environment=tj-devlab'
export OTEL_EXPORTER_OTLP_ENDPOINT='http://localhost:4317'
java -javaagent:./splunk-otel-javaagent.jar -Dsplunk.metrics.enabled=true -jar build/libs/spring-petclinic-2.4.5.jar

