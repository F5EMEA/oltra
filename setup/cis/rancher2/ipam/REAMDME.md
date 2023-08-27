# If migrating to a new k8s cluster

Keep in mind that IPAM requires storage. 
We have created a local path (folder) needs to exist `/home/ubuntu/ipam` (or change it accordingly) and it needs to run on a single node that the path exists. See below
```
  local:
    path: /home/ubuntu/ipam
```
```
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - "node01"
```