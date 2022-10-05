# Keycloak

# Deploy Keycloak into kubernetes

## Step 1. Create keycloak namespace

Access the terminal on the VS Code.

<img src="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png" style="width:40%">

Create the namespace for the keycloak services

```
kubectl create namespace keycloak
```

## Step 2. Deploy Keycloak

The first step is to import our `realm` configuration via a `ConfigMap`. The configmap will be mounted into the keycloak pod
as a volume under `/opt/keycloak/data/import` and because we pass in the `--import-realm` argument to keycloak it will import
the `OltraKeyCloak` realm for us.

```
kubectl apply -f kc-configmap.yaml
```

We can now create the deployment and service for keycloak

```
kubectl apply -f keycloak.yaml
```

## Step 3. Check all is well

Check that the pod is running

```
kubectl -n keycloak get all
```

If all is well, then you should be able to connect to the `EXTERNAL-IP` address assigned to the service by the BigIP. Eg:

>NAME                            READY   STATUS    RESTARTS   AGE
>pod/keycloak-78c5cd894b-7cpnv   1/1     Running   0          14m
>
>NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
>service/keycloak   LoadBalancer   10.101.45.193   10.1.10.170   8080:30086/TCP   5h37m
>
>NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
>deployment.apps/keycloak   1/1     1            1           5h37m
>
>NAME                                  DESIRED   CURRENT   READY   AGE
>replicaset.apps/keycloak-78c5cd894b   1         1         1       30m

Open the Keycloak admin interface in your browser http://10.1.10.170:8080/admin/master/console

## Step 4. Tweak/Add Clients

A realm called `OltraKeyCloak` was imported at start-up which contains a client configuration called `nginx-oidc`.
This is ready to provide idp services to NGINX ingress/proxies but you will likely need to edit the client settings
to update the `redirect` and `logout` urls to match the IP address for the service.

The realm includes a single user `buck` who has the password `nginxFTW`

You can test the keycloak idp with the following use-cases:

* [NGINX Custom OIDC Flow use-case](../../use-cases/nic-examples/custom-templates/custom-oidc-flow)




