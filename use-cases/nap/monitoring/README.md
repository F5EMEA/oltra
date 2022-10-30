# NGINX App Protect WAF Dashboard

> This is a dashboard for NGINX App Protect WAF. The overall solution uses Logstash to receive logs from NGINX App Protect, process them and finally store them in Elasticsearch indexes. Grafana retrieves the logs from the Elastic indexes and helps us visualize them.

<img src="images/attack-signatures-0.png"/>


## Table of Contents

- [Available Dashboards](#available-dashboards)
- [Generating Attacks](#support)

---

## Available Dashboards

### Main Dashboard
The main dashboard that provides an overview of all the violations that have been logged by NGINX App Protect WAF. From this table you can navigate to the other dashboards like SupportID, by clicking on the links. Some of the graphs/tables included in this dashboard are:
- Attacks recorded and mitigated
- Violation categories
- Attacks over time
- Mitigated Bots 
- GeoMap
- Attacks per URL
- Attack Signature detected
- Bot activity per IP/Country
- Bot activity per Policy/Device
- CVEs and Threat Campaigns
- Logs

<p align="center">
<img width="960" src="images/nap1.png"/>
</p>

### Attack Signature Dashboard
The Attack Signature dashboard provides all details for the signatures that were triggered by NGINX App Protect WAF. Some of the graphs/tables included in this dashboard are:
- Signature Hits
- Signature Accuracy and Risk
- Signatures per Context 
- Signature details 
- Signatures per URL/IP/Policy
- Parameter Names and Values
- Header Names and Values
- Cookies Names and Values
- Logs

<p align="center">
<img width="960" src="images/attack-signatures-1.png"/>
</p>

### Bot Dashboard
The Bot Dashboard provides all details for the Bot activity that was logged by NGINX App Protect WAF. Some of the graphs/tables included in this dashboard are:
- Bot Types
- Bot Categories
- Bot Activity over time
- Mitigated Bots 
- Bot activity per URL
- Bot activity per IP/Country
- Bot activity per Policy/Device
- Logs

<p align="center">
<img width="960" src="images/bot-1.png"/>
</p>

### SupportID Dashboard
The SupportID Dashboard provides all details for a specific transaction that was logged by NGINX App Protect WAF. These include the following:
- Client/Server Information (Client IP/Port, Server IP/Port, X-Forwared-For, etc)
- Violation Details (Outcome, Request Status, Outcome Reson, etc)
- Bot Details (Bot Classm Bot Category, Bit Signature, etc)
- Device Details (NAP Device name, Vritual Server Name)
- Signatures Triggered
- Treat Campaign triggered
- Violation list
- Many more

It also includes both the original and decoded Elasticsearch indices for better troubleshooting.

<p align="center">
  <img width="960" src="images/support1.png">
</p>


### Dashboards under development
The following dashboard are currently under development and should be released shortly:
- File Type Violations
- Header/Cookie Violations
- Parameter Violations
- Evasion Techniques
- HTTP Protocol Compliance
- URL Violations

## Generating attacks
In the following section we will generate multiple attacks so that the dashboards get populated with meaningful data that we can review.


### Step 1. Deploy and protect a web application  

Create the application deployment and service in namesapce `monitoring-nap`:
```
kubectl apply -f apps.yaml
```

Create the App Protect policy.
```
kubectl apply -f appolicy.yml
```

Create log configuration resource:
```
kubectl apply -f log.yml
```

Create the policy to reference the AP Policy, the AP Log profile and the log destination.
```
kubectl apply -f policy.yaml
```

Create the VirtualServer resource:
```
kubectl apply -f virtual-server.yaml
```

Send a request to the application. We 'll use the --resolve option to set the Host header of a request with `webapp.f5demo.local`

```
curl --resolve webapp.f5demo.local:80:10.1.10.10 http://webapp.f5demo.local/

#####################  Expected output  #######################
Server address: 10.244.140.109:8080
Server name: webapp-7586895968-r26zn
Date: 12/Sep/2022:14:12:25 +0000
URI: /
Request ID: 0495d6a17797ea9776120d5f4af10c1a
```

### Step 2. Execute malicious requests to the application  

Now, let's try to send a malicious request to the application:
```
####SQL Injection (encoded)####
curl "http://tea.f5demo.cloud/index.php?password=0%22%20or%201%3D1%20%22%0A"
####SQL Injection####
curl "http://tea.f5demo.cloud/index.php?password==0'%20or%201=1'"
####SQL Injection####
curl "http://tea.f5demo.cloud/index.php?id=%'%20or%200=0%20union%20select%20null,%20version()%23"
####Cross Site Scripting####
curl "http://portal.f5demo.cloud/index.php?username=<script>"
####Command Injection####
curl "http://cafe.f5demo.cloud/index.php?id=0;%20ls%20-l"
```

The expected output  for all the previous requests is the following:
``` <html><head><title>Request Rejected</title></head><body>The requested URL was rejected........ ```

### Step 3. Review the violations with the Grafana Dashboards 

To review the violations login to Grafana and search with the support ID. More information regarding NAP Grafana Dashboard can be found on the <a href="link"> monitoring </a> lab

***Clean up the environment (Optional)***
```
kubectl delete -f .
```
