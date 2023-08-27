# Upgrade of CIS
1. Review/Compare the following files
   - https://github.com/F5Networks/k8s-bigip-ctlr/blob/master/docs/config_examples/rbac/clusterrole.yaml
   - /home/ubuntu/oltra/setup/cis/cis/cis-cluster-role.yml

2. Copy the new CRDs and change the shortnames

    - https://github.com/F5Networks/k8s-bigip-ctlr/blob/master/docs/config_examples/customResourceDefinitions/customresourcedefinitions.yml
    - /home/ubuntu/oltra/setup/cis/cis/cis-crd.yml

```
Before
    shortNames:
      - vs
      
After
    shortNames:
      - f5-vs
```