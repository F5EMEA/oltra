# Establishing a DevSecOps Framework with BIGIP

With the BIGIP automation [use-case](https://github.com/F5EMEA/oltra/tree/main/use-cases/automation/bigip) we already streamlined the deployment of VirtualServers and WAF policies to our BIGIP devices. In this use-case we are establishing a DevSecOps framework that the SecOps teams can use to automate the operational aspect of the WAF policies (Day 2 operations). 
It is essential that you review the use-case [Automating BIG-IP with Per-App AS3 and GitOps](https://github.com/F5EMEA/oltra/tree/main/automation/bigip) as this use-case is an extension of that use-case


In order for the SecOps team to be successful on the Day 2 operations of the WAF policies the following components are required:
  - Automating the deployment of Virtual Servers
  - Git to store the WAF declarations
  - CI/CD tool to deploy the changes/updates
  - Observability platform
  - WAF Policy Management Tool


### VirtualServer Automation
Automating the deployment of Virtual Servers on BIGIP has already been covered on the BIGIP automation [**use-case**](https://github.com/F5EMEA/oltra/tree/main/automation/bigip) and it is a pre-requisite for the DevSecOps framework.

### Git and CI/CD
Git stands as the definitive source of truth for storing both SecOps and DevOps code. As the most popular and widely used version control system today, Git boasts numerous advantages: code changes are seamlessly committed, version branches effortlessly compared and merged, and code optimization facilitated.
As described on the **Automation use-case**, during the deployment of the VirtualServer, the WAF policies have already been created and stored on a separate WAF repository from which, AS3 will intially pull the confguration. 
While the customer has the option to use the BIGIP UI to manage the WAF policies, once created via AS3, in this scenario we will be discussing the option of using Git as the source of truth of WAF.

In order to this to be feasible the SecOps will have to save their updated WAF configuration in a new Branch where the configuration will be validated and once it is approved the WAF policy will be pushed down to the BIGIP.

Within the WAF repository, we've implemented two pipelines:

  - **Merge Pipeline**. This pipeline is designed to prevent the merging of code that could potentially fail upon deployment to BIG-IP. Therefore, the pipeline must succeed before allowing administrators to merge the branch to the main branch. To mitigate the risk of failures in WAF configurations, the pipeline validates the WAF policies that have been modified with the OpenAPI spec of the BIGIP WAF to ensure that the final pipeline will consistently succeed post-merger. 

<p align="center">
  <img src="images/merge-pipeline.png" style="width:45%">
</p>

  - **WAF Pipeline**. The purpose of the this pipeline, is to identify the modified WAF policies and push them down to the corresponding BIGIP. The pipeline is split in 3 stages
    - **Changes Detection**: This initial stage identifies WAF declarations that have been added, modified, or deleted. The filenames are recorded for subsequent processing in later stages.
    - **Update**: In the final stage, the pipeline pushes down the new WAF policy to the respective BIG-IP devices, ensuring consistent configuration across the infrastructure.
 
<p align="center">
  <img src="images/waf-pipeline.png" style="width:65%">
</p>

The pipeline configuration for the WAF repo can be found on the following [**file**](https://github.com/f5emea/oltra/use-cases/devsecops/bigip/pipelines/waf-pipeline.yml)


### Observabilty platform
Establishing an observability platform is essential for effective management of a Web Application Firewall (WAF) solution. The data collected from BIGIP AWAF aids SecOps teams in identifying and mitigating threats associated with published applications. In our setup, Logstash serves as both the log transformer and shipper. By leveraging Logstash, we ensure streamlined data collection and analysis, enhancing the scalability and efficiency of our observability platform.

In our environment, Logstash, is deployed alongside Elastic and Grafana to construct the observability platform for BIGIP AWAF. All BIGIP Devices send their events/logs to this platform, providing SecOps teams with a centralized dashboard for monitoring security events.

<p align="center">
  <img src="images/dashboard.png" style="width:70%">
</p>

More information regarding NAP Grafana Dashboard can be found on the [**BIGIP WAF Dashboard**](https://github.com/F5EMEA/oltra/tree/main/monitoring/bigip-waf) lab



### Managing NAP policies
Managing AWAF policies is integral to the policy lifecycle, especially in addressing potential false positives. While F5 AWAF algorithms strive to minimize false positives, readiness is key for SecOps teams. The observability platform aids in identifying false positives by aggregating and visualizing metrics/events from multiple BIGIP Devices and SecOps teams can then adjust the WAF policies accordingly, excluding specific signatures or any other configuration as needed.

There are mulitple ways for the WAF policies to be fine-tuned based on the events that have been identified as false positive. These are:
- **Manual**. SecOps teams can edit manually the JSON files that are stored on GitLab.
- **Automated**. Tools like Ansible, Puppet, Terraform and many others can provide an automated procedure for the SecOps to make the necessary changes on the JSON policies stored on GitLab

To convert a violation into a false positive exception on the WAF configurations, the SecOps teams have to modify the WAF policy with the required JSON key/value pairs. The example below shows how a policy needs to be modified to exclude particular signatures from a policy.

<p align="center">
  <img src="images/policy-modify.png" style="width:70%">
</p>


In this demo we will be using a Ansible-Tower opensource project, AWX, to modify the WAF policies. Details on this project can be found on the following repository [**Managing WAF policies with Ansible**](https://github.com/F5EMEA/oltra/tree/main/use-cases/devsecops/managing-waf-policies).  

AWX provies a very capable UI, that  tool provides the user predefined templates for modifying the WAF configuration based on the events analyzed from Grafana.
 
<p align="center">
  <img src="images/awx.png" style="width:70%">
</p>

Depending on the template the user will select, AWX  provides the user predefined fields and drop-downs for modifying the WAF configuration. For example, as seen on the above picture, `Disable Signature` and `Disable Signature on URL`.

<p align="center">
  <img src="images/awx-signatures.png" style="width:55%">
</p>



## Demo

### Step 1-8. Automation Lab 
In order to successfully go through the demo below, you must first complete the Automation labs that will deploy the VirtualServer and WAF policy that we will be using.
- [**BIGIP Automation**](https://github.com/F5EMEA/oltra/tree/main/automation/bigip)


### Step 9. Generate an Attack



### Step 10. Review Attack on Grafana



### Step 11. Make an exeption for the Signature IDs



### Step 12. Review and Accept changes on GitLab



### Step 13. Repeat the Attack

