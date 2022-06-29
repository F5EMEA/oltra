# Monitoring services published via BIGIP with Prometheus, Grafana and Elastic
In this section we go through how you can efectively to monitor your BIGIP devices with an observability platform which is typically used by modern architectures. 
The technologies as part of the observability platform are the following:
- Prometheus
- Logstash
- Elasticsearch
- Grafana
- Telemetry Streaming (F5)

The dashboards that have been created to assist with the monitoring of the BIGIP devices are:
  - CIS Dashboard
  - Client/Server SSL Performance
  - HTTP Profiles
  - Pools
  - VS Access Logs
  - BIGIP Error Logs (to be completed)

## CIS Dashboard
This is the main dashboard that will be used to have an overall view on the utilization and performance of the applications handled by BIGIP. All the information for this dashboard is coming from Prometheus.
<img src="https://raw.githubusercontent.com/skenderidis/oltra/main/use-cases/bigip-monitoring/images/dashboard.png">

The dashboard provides visibility on the following:
- Total number of Virtual Servers, Pools and Members
- HTTP Reponse Codes (2xx, 3xx, 4xx and 5xx) for the specific period across the entire appliance
- Pool availability (requires a monitor to be assinged to the pool)
- Virtual Servers statistics (with drill in capabiltiy)
- Pool statistics (with drill in capabiltiy)
- Client/Server SSL Profile stastics 
- HTTP Profile stastics 
- Utilization and L7 TPS over time

## Client SSL Dashboard
In this dashboard we can check multiple SSL metrics, from the SSL version, to the cipher, to the key exhange used. We can verify any SSL failure and check if the SSL offloading is happening on hardware or software.
<img src="https://raw.githubusercontent.com/skenderidis/oltra/main/use-cases/bigip-monitoring/images/client-ssl.png">

## Server SSL Dashboard
In this dashboard we can check multiple SSL metrics, from the SSL version, to the cipher, to the key exhange used. We can verify any SSL failure and check if the SSL offloading is happening on hardware or software.
<img src="https://raw.githubusercontent.com/skenderidis/oltra/main/use-cases/bigip-monitoring/images/client-ssl.png">


## Pools Dashboard
In this dashboard we provide more details on the utilization and transaction for a specific pool and its memebers. You can also monitor Pool member's availability along with statistics and utilization over time. 
<img src="https://raw.githubusercontent.com/skenderidis/oltra/main/use-cases/bigip-monitoring/images/client-ssl.png">


## HTTP Profile Dashboard
In this dashboard we get the HTTP response code (2xx, 3xx, 4xx, 5xx) per HTTP Profile and we can observe the behaviour over time.
<img src="https://raw.githubusercontent.com/skenderidis/oltra/main/use-cases/bigip-monitoring/images/client-ssl.png">

## VS Access Logs
In this dashboard we get the HTTP response code (2xx, 3xx, 4xx, 5xx) per HTTP Profile and we can observe the behaviour over time.
<img src="https://raw.githubusercontent.com/skenderidis/oltra/main/use-cases/bigip-monitoring/images/client-ssl.png">






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
