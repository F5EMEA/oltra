# Implementing DevSecOps on BIG-IP with AS3

Implementing DevSecOps on BIG-IP aims to streamline and automate the deployment of configurations while integrating security practices seamlessly into the VirtualServer deployment process. This use case outlines the process of translating customer requirements specified in YAML format into AS3 declarations using JINJA2 templates, integrating WAF policies and automating the deployment process onto F5 BIG-IP.



## Required Components
In order to build an infrastructure that can accomodate for both SecOps and DevOps, we will need the following:

- Automating the deployment of BIGIP
- Git repository 
- Observability Platform
- Policy Management Process
- CI/CD tool(s)

**Overview**

- Customer Requirements Specification: The customer defines their requirements in a simplified YAML file format.
- Pipeline Execution: A CI/CD pipeline is triggered upon changes to the YAML file. The pipeline fetches the YAML file and starts the process.
- Input Validation: Upon receiving the YAML file, the pipeline performs input validation to ensure that the provided specifications are well-formed and adhere to the expected schema, but also adhere to the security requirements set by the team.
- AS3 Declaration Generation: The pipeline uses JINJA2 templates to transform the YAML specifications into AS3 declarations, which define the desired configurations for the BIG-IP.
- WAF Policy Creation: If WAF functionality is required, the pipeline creates a new WAF policiy for the application.
- Upstream Repositories: Both AS3 Declaration and the newly created WAF policy are pushed on downstream
repositories that are managed by the BIGIP and security teams respectively.
- Configuration Review: The generated AS3 declaration are pushed on a Branch of the BIGIP Repo, by the customer's pipeline, and a Merge Request in order for the configuration to be reviewed.
- Configuration Approval: Once the Merge Request is approved, the configurations are pushed to F5 BIG-IP devices for deployment. AS3 will pull the WAF policy from the security repo.

WAF pipeline

- Configuration Review: The generated AS3 declaration are pushed on a Branch of the BIGIP Repo, by the customer's pipeline, and a Merge Request in order for the configuration to be reviewed.
- Configuration Approval: Once the Merge Request is approved, the configurations are pushed to F5 BIG-IP devices for deployment. AS3 will pull the WAF policy from the security repo.


<IMAGE>
