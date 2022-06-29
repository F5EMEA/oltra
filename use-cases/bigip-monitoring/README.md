# Monitoring services published via BIGIP with Prometheus, Grafana and Elastic
In this section we go through how you can efectively to monitor your BIGIP infrastructure on modern architecture. 


The technologies that are being used to provide the analytics are the following:
- Telemetry Streaming
- Prometheus
- Logstash
- Elasticsearch
- Grafana


  - Virtual Server Utilization 
  - Pool Utilization 
  - HTTP Profile Statistics
  - SSL Statistics
  - Virtual Access Logs
  - BIGIP Error Logs


**Telemetry Streaming**

Telemetry Streaming (TS) enables you to declaratively aggregate, normalize, and forward statistics and events from the BIG-IP to a consumer application. There are 2 type of consumers; Push and Pull Consumer. <br>
The Push consumer that that has been configured is sending all the access logs to ElasticSearch. The pre-requisite for this is to attach the `name` iRule on to the Virtual Server that you want to send the logs to Elastic. 
The Prometheus Pull Consumer has also been enabled in order to expose a new HTTP API endpoint that can be scraped by Prometheus for metrics. The Prometheus Pull Consumer outputs the telemetry data according to the Prometheus data model specification. 

**Prometheus**

Prometheus has been configured to scrape both BIGIP and CIS for all metrics every 30 seconds.

**Elasticsearch**

Elasticsearch is configure to received logs 


**BIGIP Access logs**

Prometheus has been configured to scrape both BIGIP and CIS for all metrics every 30 seconds

## Setup (pending)

The solution has already been deployed on 
