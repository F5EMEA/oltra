# NAP Demo

In this example we deploy the NGINX Plus Ingress Controller with [NGINX App Protect](https://www.nginx.com/products/nginx-app-protect/) and we will create different types of violations and review their logs. 
The violations are:

Working with Signatures
- Enabling Signature-Sets
- Creating your own Signature-Sets
- Modifying the policy

HTTP Compliance


Evasion Techniques


Working File Types


Working with Cookies


Working with Headers


Working with parameters







- Enabling Signature 
- Different types of Signature-based
- HTTP Compliance
- Evasion technique
- File type extension
- Cookie name 
- Cookie va

### Pre-requisites
Deploy an application and apply the Base WAF policy to protect it. 


## Step 1 - Create multiple Ingress and VS CRDs
Change the working directory to `nap`.
```
cd ~/oltra/use-cases/nap/
```

Deploy apps `coffee`, `tea` and `www` that are configured on `apps.yml`
```
kubectl apply -f apps.yml
```

Deploy NAP policies for `coffee`, `tea` and `www`.
```
kubectl apply -f nap-policy-coffee.yml
kubectl apply -f nap-policy-tea.yml
kubectl apply -f nap-policy-www.yml
```

Create the APLogConf CR to define NAP's maximum request size the filter. We have selected 10kbytes for the log size and only log illegal requets
```
kubectl apply -f log.yml
```

Now that we have all components in place we can create the Ingress resources and define the NAP and Log policies that each ingress should use. On Ingress resources this is achieved through annotations
```
  annotations:
    appprotect.f5.com/app-protect-policy: **<policy name>**
    appprotect.f5.com/app-protect-enable: **True/False**
    appprotect.f5.com/app-protect-security-log-enable: **True/False**
    appprotect.f5.com/app-protect-security-log: **<namespace/log-profile-name>**
    appprotect.f5.com/app-protect-security-log-destination: **"syslog:server=IP-address:Port"**
```

Deploy the Ingress resources for the 3 services.
```
kubectl apply -f ingress-cafe.yml
kubectl apply -f ingress-tea.yml
kubectl apply -f ingress-portal.yml
```

Verify that you can now reach successfully the Ingress resources
```
curl http://tea.f5demo.cloud
curl http://cafe.f5demo.cloud
curl http://portal.f5demo.cloud
```
```
###############   expected result   ###############
Server address: 10.244.140.114:80
Server name: portal-7c674cffbd-nkzrx
Date: 15/Aug/2022:06:57:25 +0000
URI: /
Request ID: 19ed141c6c09aa8833f86c40b6780308
####################################################
```


## Step 2 - Send violations to Ingress resources
**Signature Violations**
Run the following commands that will trigger signature violations that include SQL Injection, Command Injection and Cross Site Scripting among others
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

Verify that the response is now coming from NGINX Ingress Controller that informs you that the transactions has been blocked.
```html
<html><head><title>Request Rejected</title></head><body>The requested URL was rejected. Please consult with your administrator.<br><br>Your support ID is: 742177367032758723<br><br><a href='javascript:history.back();'>[Go Back]</a></body></html>
```

**Illegal Methods Violations**

Run the following commands that will trigger Illegal Method violation
curl -X INSERT "http://tea.f5demo.cloud/index.php"
```
    methods:
    - name: INSERT
```

## Step 3 - Enhance the NAP policy with additional security 
In this section we will enable additional security controls for the 

#### Step 3 - Review Dashboards in Grafana
Lets review the security events on the Grafana dasbboard:
- Utilization per virtual server
- Traffic per pool and pool memebers
- HTTP Response Code statistics
- SSL utilization
- SSL failures
- SSL version used
- URLs that have slow response time and URLs that generate 500 and 404 errors

On the UDF you can acess Grafana from BIGIP "Access" methods as per the image below.

<p align="left">
  <img src="images/grafana.png" style="width:35%">
</p>

Login to Grafana (credentials **admin/IngressLab123**)
<p align="left">
  <img src="images/login.png" style="width:50%">
</p>


Go to **Dashboards->Browse**

<p align="left">
  <img src="images/browse.png" style="width:22%">
</p>


Select any Dashboard you want to review under CIS

<p align="left">
  <img src="images/dashboards.png" style="width:90%">
</p>
