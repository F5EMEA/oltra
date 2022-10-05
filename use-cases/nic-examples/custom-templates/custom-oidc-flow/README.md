# OpenID Connect Custom Authorization Flow

This use-case comes from a prospect providing a SaaS based scheduling and people management solution in the health sector. The requirement was for a Kubernetes Ingress solution which could integrate with a customers iDP and provide OIDC authentication information to an API services pods.

- [OpenID Connect Custom Authorization Flow](#openid-connect-custom-authorization-flow)
- [The problem](#the-problem)
- [The Solution](#the-solution)
- [Try it for yourself](#try-it-for-yourself)
  - [Step 1. Deploy an Ingress Controller](#step-1-deploy-an-ingress-controller)
  - [Step 2. Confirm your Ingress is up and running](#step-2-confirm-your-ingress-is-up-and-running)
  - [Step 3. Deploy keycloak](#step-3-deploy-keycloak)
  - [Step 4. Deploy our Demo application](#step-4-deploy-our-demo-application)
  - [Step 5. Test](#step-5-test)

# The problem

The OIDC authentication requirements for a service/location wouldn't be known prior to accessing the API, so the customer only wanted the OIDC flow to operate when the Ingress received a `HTTP 401` response from the API pod. In other words we needed to pass through a request to the upstream as-is, and only kick off OIDC if the backend denied the request. This is not how the out-of-the-box templates operate. Customization would be required.

The default OIDC location authentication directives would attempt to authorize inbound connections with `auth_jwt` and kick off OIDC via `@do_oidc_flow` if the authorization failed. This is the behaviour we needed to change.

```yml
    {{ if $l.OIDC }}
        auth_jwt "" token=$session_jwt;
        error_page 401 = @do_oidc_flow;
        auth_jwt_key_request /_jwks_uri;
        {{ $proxyOrGRPC }}_set_header username $jwt_claim_sub;
    {{ end }}
```
> source: [NGINX Plus virtualserver template](https://github.com/nginxinc/kubernetes-ingress/blob/main/internal/configs/version2/nginx-plus.virtualserver.tmpl)

# The Solution

We needed to control when the OIDC flow was started. The solution was to pass all unauthenticated requests to the backend, but to validate JWTs on requests which already had tokens. In the event that an unauthenticated client recieved a `HTTP 401`, then we start the OIDC flow. This required adding a `map` to the server context:

```yml
    {{ with $oidc := $s.OIDC }}
    map $session_jwt $do_oidc_auth {
      default   "";
      ""        "off";
    }
    {{ end }}
```

This sets a variable called `$do_oidc_auth` which would either be empty if a `$session_jwt` variable existed (indicating a token was present), or set to "off" if no such token existed. With this added to the server block, we could modify the location template to look like this:

```yml
    {{ if $l.OIDC }}
        {{ $proxyOrGRPC }}_intercept_errors on;
        auth_jwt $do_oidc_auth token=$session_jwt;
        error_page 401 = @do_oidc_flow;
        auth_jwt_key_request /_jwks_uri;
        {{ $proxyOrGRPC }}_set_header username $jwt_claim_sub;
        {{ $proxyOrGRPC }}_set_header jwtToken $session_jwt;
    {{ end }}
```
Now the `jwt_auth` directive uses the `$do_oidc_auth` variable to determine whether to authenticate the user or not, and the `proxy_intercept_errors` directive is required for the `@do_oidc_auth` flow to operate in the case where a `HTTP 401` is received from the upstream. We also pass through the full JWT Token to the upstream in a header called jwtToken.

With these few changes we were able to completely change the way the OIDC flow was implemented in the Ingress Controller.

# Try it for yourself

## Step 1. Deploy an Ingress Controller

Copy the IC setup files to the local folder and patch them

```
cp -rp ~/oltra/setup/nginx-ic nginx-ic
patch -p0 < oidc.patch
``` 

This will patch the NGINX IC files to use the `nginx-oidc` namespace, and add our custom template to the NGINX ConfigMap. 
See the created `nginx-ic/resources/nginx-config.yaml` for the full `virtualserver` template.

Next we create the namespace and resources needed for the Ingress Controller

```
kubectl apply -f nginx-ic/rbac
kubectl apply -f nginx-ic/resources
```

Finally add your `regcred` secret for access to the NGINX Private registry, and then deploy the Ingress Controller
```
kubectl create secret docker-registry regcred --docker-server=private-registry.nginx.com --docker-username="<JWT>" --docker-password=none -n nginx-oidc
kubectl apply -f nginx-ic/nginx-plus
kubectl apply -f nginx-plus-service.yaml
```
## Step 2. Confirm your Ingress is up and running

Check the Ingress deployment with:

```
kubectl -n nginx-oidc get all
```
Confirm that the pods are running, and the service has returned an `EXTERNAL-IP` address. Make a note of the external IP, because you'll
need to provide it to keycloak in the next step.

```bash
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/nginx      LoadBalancer   10.101.45.193   10.1.10.171   8080:30086/TCP   5h37m
```

## Step 3. Deploy keycloak

Head on over to [The Keycloak Setup instructions](../../../../setup/keycloak/README.md) and deploy a keycloak service in the cluster.

> ### NOTE 
> Remember to update the IP address in the redirects to match your Ingresses `EXTERNAL-IP`

## Step 4. Deploy our Demo application

We now have an Ingress controller with OIDC capabilities, and an idp ready to provide authentication.
The next step is to deploy our demo application.

The demo appliction is a simple NGINX deployment which is configured with two locations:

```nginx
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        location /protected {
            add_header x_username $http_username always;
            add_header x_protected "true" always;
            root   /usr/share/nginx/html;
            if ( $http_username = "" ) {
                return 401;
            }
            default_type text/plain;
            return 200 "Welcome to /protected $http_username\nToken: $http_jwtToken\n";
```

The root(/) location returns the standard NGINX Welcome page, and the /protected location returns a text
page which includes a couple of headers injected by the Ingress controller. The /protected location is
configured to return a `HTTP 401` if the Ingress controller does not set the `username` header.

The `VirtualServer` resource is configured to required OIDC authentication for all locations, and if it
were using the default template all access would require the client to have a JWT, but due to our new
logic you should be able to access all content on the application until the app returns a `401`.

Deploy the application
```bash
kubectl apply -f nginx-oidc-demo-app.yaml
```

You may need to check the `oidc-poilcy.yaml` at this point and update the urls to use the `EXTERNAL-IP` address
assigned to your KeyCloak service.

```bash
kubectl -n keycloak get service/keycloak
```

Deploy the OIDC Secret and Policy
```bash
kubectl apply -f oidc-secret.yaml
kubectl apply -f oidc-policy.yaml
```

Finally deploy the VirtualServer to configure the Ingress. Again you might need to update the `Host` parameter
to match the `EXTERNAL-IP` given to your Ingress Controller.

```bash
kubectl apply -f virtualserver.yaml
```

## Step 5. Test

You should now be able to hit your ingress controller on it's External IP and see a "Welcome to NGNIX" page.
this page is accessable without authentication, because the upstream server returned the content wihout requiring
authentication.

If you attempt to acess the `/protected` resource, you should go through the OIDC flow because the upstream returns
a `HTTP 401` and we initiate the OIDC authentication with Keycloak.

Enjoy!
