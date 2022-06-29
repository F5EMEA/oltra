# OLTRA
**One lab to rule them all (OLTRA)**
This repository contains examples, use-cases and demos for modern architectures that you can use with the "OLTRA" UDF deployment that is maintained by the EMEA Solution Architect team.
Below you can find the network diagram for the lab.

<img src="https://raw.githubusercontent.com/skenderidis/f5-ingress-lab/main/setup/images/udf-lab.png">


The technologies that are being used for the lab are the following

| Name | Notes | IP Address | Access Methods |
|---|---|---|---|
| **BIGIP (15.1)** |  Standalone BIGIP that has the LTM/ASM/DNS/AFM modules provisioned. | 10.1.1.4 | SSH / HTTPS |
| **NGINX KIC** | Runs in K8s. There are 2 deployments of NGINX KIC. <br>One defined with IngressClass `infra` and the other with `plus`. The main IngressClass that will be used throughout the demos/use-cases is `plus`.  | - | - |
| **CIS** | Runs in K8s. `CIS-CRD` instance is used to deploy services based on VirtualServer/TransportServer CRDs and ServiceType LB whereas `CIS-Ingress` instance is used for Ingress Resources and ConfiMaps | - | - |
| **GitLab** | Runs on a dedicated server and provides three functionalities; source code management, CI/CD and Docker registry. | 10.1.1.8 | HTTPS |
| **ArgoCD** | Runs as a pod in K8s and published through CIS| 10.1.1.8 | HTTPS |
| **Elasticsearch** | Elastic runs as an instance on the "Docker" system and its main purpose is to store the Access, Error and Security logs for NAP, NGINX and BIGIP.  | 10.1.1.8:9200 | HTTPS |
| **Logstash** | Logstash runs as an instance on the "Docker" system and its main purpose is to process the logs, parse them and then forward them to Elastic.  | 10.1.1.8:515 | - |
| **K8s Master** | - | 10.1.1.5 | SSH |
| **K8s Node1** | - | 10.1.1.6 | SSH |
| **K8s Node2** | - |  10.1.1.7 | SSH |
| **VSCode** | Runs VScode through a web interface on the "Client" system. |  10.1.1.7 | HTTP |
| **Prometheus** | Runs in K8s and provides a time-series storage for monitoring both BIGIP and NGINX+. |  10.1.1.19 | HTTP |
| **Grafana** | Multiple Dashboards have been developed for displaying metrics/events from both Prometheus and Elastic. Runs in K8s. |  10.1.1.20 | HTTP |


Credentials are documented inside the UDF Summary page.

## Use-Cases / Demos
In this UDF we will demo a number of use-cases around modern applications. These use-cases can be found below:

- [**Reverse Proxy capabilities with CIS**](examples/cis/README.md)
- **Monitoring K8s services published via NGINX+ Ingress Controller with Prometheus, Grafana and Elastic** <br>
- **Monitoring K8s services published via BIGIP with Prometheus, Grafana and Elastic** <br>


- **Publishing NGINX+ Ingress with BIGIP** <br>
- **DNS Publishing of K8s services with CIS EDNS CRDs** <br>
- **Deploy Active-Active or Active-Standby services in a multicluster K8s with CIS and NGINX** <br>
- **ServiceType LoadBalancer with BIGIP** <br>
- **Securing K8s services against L3 DDoS attacks with BIGIP** <br>
- **Securing K8s services against L7 DDoS attacks with NGINX+** <br>
- **Protecting K8s applications against web application attacks with BIGIP/NGINX+** <br>

