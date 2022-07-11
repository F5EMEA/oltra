# OLTRA
**One lab to rule them all (OLTRA)**

This repository contains examples, use-cases and demos for modern architectures that you can use with **OLTRA**. OLTRA can be deployed either in F5's [UDF environment](https://udf.f5.com/b/94afd04b-a46b-4429-b2e1-2b3ac9813579) or in the public cloud provider of your choice ([AWS](/deployment/aws) or [Azure](/deployment/azure)) with the use of Terraform/Ansible. OLTRA is maintained by the EMEA Solution Architect team.

The high level diagram for OLTRA environment can be found below along with the technologies that are being used on this lab.

<img src="https://raw.githubusercontent.com/skenderidis/f5-ingress-lab/main/setup/images/udf-lab.png">


| Name | Notes |
|---|---|
| **BIGIP (15.1)** |  Standalone BIGIP that has the LTM/ASM/DNS/AFM modules provisioned. | 
| **NGINX KIC** | Runs inside the K8s cluster. There are 2 primarly deployments of NGINX KIC. <br>One deployment with IngressClass `infra` that handles infrastructure components like Prometheus, Grafana and ArgoCD and another deployment with ingressclass `plus` that uis used for demos, use-cases and examples. The NGINX+ Ingress Controller version used is 2.2.2 |
| **CIS** |  Runs inside the K8s cluster. There are 2 CIS instances running inside the cluster. `cis-crd` instance is used to deploy services based on VirtualServer/TransportServer CRDs and ServiceType LB whereas `cis-ingress` instance is used for Ingress Resources and ConfiMaps |
| **K8s Cluster** | 3 node Kubernetes cluster (Master, Node01 and Node02) running verion 1.22|
| **GitLab** | Runs on a dedicated server and provides three main functionalities; source code management, CI/CD and Docker registry. |
| **ArgoCD** | Runs as a pod in K8s |
| **Elasticsearch** | Elastic runs as an instance on the "Docker" system and its main purpose is to store the Access, Error and Security logs for NAP, NGINX and BIGIP.   |
| **Logstash** | Logstash runs as an instance on the "Docker" system and its main purpose is to process the logs, parse them and then forward them to Elastic.   |
| **VSCode** | Runs VScode through a web interface on the "Client" system. |
| **Prometheus** | Runs in K8s and provides a time-series storage for monitoring both BIGIP and NGINX+. |
| **Grafana** | Multiple Dashboards have been developed for displaying metrics/events from both Prometheus and Elastic. Runs in K8s. |

Credentials are documented inside the UDF Summary page.

## Use-Cases
The use-case build for OLTRA can be found below:

- **Building Multi-tenant Ingress services** <br>
- **Deploying Active-Active or Active-Standby services in a multicluster K8s with CIS and NGINX** <br>
- **Implementing eb application security into a DevOps environment**


## Demos
The demos build for OLTRA can be found below:

- **Monitoring K8s services published via BIGIP with Prometheus, Grafana and Elastic** <br>
- **Monitoring K8s services published via NGINX+ Ingress Controller with Prometheus, Grafana and Elastic** <br>
- **Publishing NGINX+ Ingress with BIGIP** <br>
- **Securing K8s services against L3/L7 DDoS attacks with BIGIP** <br>
- **Securing K8s services against L7 DDoS attacks with NGINX+** <br>
- **Protecting K8s applications against web application attacks with BIGIP** <br>


## Examples
The examples build for OLTRA can be found below:

- [**Reverse Proxy capabilities with CIS**](examples/cis/README.md)
- **DNS Publishing of K8s services with CIS EDNS CRDs** <br>
- **Publishing services with Type LoadBalancer with CIS** <br>
- **Continuous Deployment with ArgoCD** <br>

