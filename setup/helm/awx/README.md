# Installing AWX

1. We will deploy AWX to the secondary Cluster (Rancher2).

Install with Helm (default values)
helm repo add awx-operator https://ansible.github.io/awx-operator/
helm install -n awx --create-namespace ansible awx-operator/awx-operator


2. Create a demo instance (demo.yaml)
k apply -f /home/ubuntu/oltra/setup/awx/demo.yaml


3. Publish it with CIS
k apply -f /home/ubuntu/oltra/setup/awx/publish-awx.yml


4. Get admin password
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode


5. Login and change password


6. Add a custom execution environment that will contain the collections you want.
In our case we are using this image "skenderidis/custom-ee"
