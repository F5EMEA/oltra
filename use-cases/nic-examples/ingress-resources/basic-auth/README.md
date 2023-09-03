# Support for HTTP Basic Authentication

NGINX supports authenticating requests with [ngx_http_auth_basic_module](https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html).

The Ingress controller provides the following 2 annotations for configuring Basic Auth validation:

* Required: ```nginx.org/basic-auth-secret: "secret"``` -- specifies a Secret resource with a htpasswd user list. The htpasswd must be stored in the `htpasswd` data field. The type of the secret must be `nginx.org/htpasswd`.
* Optional: ```nginx.org/basic-auth-realm: "realm"``` -- specifies a realm.

## Running the Example

Use the terminal on VS Code. VS Code is under the `bigip-01` on the `Access` drop-down menu. Click <a href="https://raw.githubusercontent.com/F5EMEA/oltra/main/vscode.png"> here </a> to see how 

Change the working directory to `complete-example`.
```
/home/ubuntu/oltra/use-cases/nic-examples/ingress-resources/basic-auth
```

## Step 1 - Deploy a Web Application

Create the application deployment and service:
  ```
  kubectl apply -f cafe.yaml
  ```

## Step 2 - Deploy the Basic Auth Secret

Create a secret of type `nginx.org/htpasswd` with the name `cafe-passwd` that will be used for Basic Auth validation. It contains a list of user and base64 encoded password pairs:
  ```
  kubectl apply -f cafe-passwd.yaml
  ```

## Step 3 - Configure Load Balancing

Create an Ingress resource for the web application:
  ```
  kubectl apply -f cafe-ingress.yaml
  ```

Note that the Ingress resource references the `cafe-passwd` secret created in Step 2 via the `nginx.org/basic-auth-secret` annotation.


## Step 4 - Test the Configuration

If you attempt to access the application without providing a valid user and password, NGINX will reject your requests for that Ingress:
  ```
  curl https://cafe.f5k8s.net/coffee
  ```

Expected result
```html
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx/1.21.5</center>
</body>
</html>
```

If you provide a valid user and password, your request will succeed:
```
curl https://cafe.f5k8s.net/coffee -u foo:bar
```

```
Server address: 10.244.0.6:8080
Server name: coffee-7b9b4bbd99-bdbxm
Date: 20/Jun/2022:11:43:34 +0000
URI: /coffee
Request ID: f91f15d1af17556e552557df2f5a0dd2
```


## Example 2: a Separate Htpasswd Per Path

In the following example we enable Basic Auth validation for the [mergeable Ingresses](../mergeable-ingress-types) with a separate Basic Auth user:password list per path:

## Step 1 - Deploy a Web Application

Create the application deployment and service:
  ```
  kubectl apply -f cafe.yaml
  ```

## Step 2 - Deploy the Master Ingress

Create the master ingress
  ```
  kubectl apply -f cafe.yaml
  ```

## Step 3 - Create Tea minion

Create the tea minion ingress and the Htpasswd password
  ```
  kubectl apply -f tea-passwd.yaml
  kubectl apply -f tea-minion.yaml
  ```


If you attempt to access the application without providing a valid user and password, NGINX will reject your requests for that Ingress:
  ```
  curl https://cafe.f5k8s.net/coffee
  ```

Expected result
  ```html
  <html>
  <head><title>401 Authorization Required</title></head>
  <body>
  <center><h1>401 Authorization Required</h1></center>
  <hr><center>nginx/1.21.5</center>
  </body>
  </html>
```

If you provide a valid user and password, your request will succeed:
```
curl https://cafe.f5k8s.net/coffee -u tea:bar
```

```
Server address: 10.244.0.6:8080
Server name: coffee-7b9b4bbd99-bdbxm
Date: 20/Jun/2022:11:43:34 +0000
URI: /coffee
Request ID: f91f15d1af17556e552557df2f5a0dd2
```

## Step 4 - Create Coffee minion

Create the tea minion ingress with the password
  ```
  kubectl apply -f coffee-passwd.yaml
  kubectl apply -f coffee-minion.yaml
  ```



If you attempt to access the application without providing a valid user and password, NGINX will reject your requests for that Ingress:
  ```
  curl https://cafe.f5k8s.net/coffee
  ```

Expected result
  ```html
  <html>
  <head><title>401 Authorization Required</title></head>
  <body>
  <center><h1>401 Authorization Required</h1></center>
  <hr><center>nginx/1.21.5</center>
  </body>
  </html>
```

If you provide a valid user and password, your request will succeed:
```
curl https://cafe.f5k8s.net/coffee -u coffee:bar
```

```
Server address: 10.244.0.6:8080
Server name: coffee-7b9b4bbd99-bdbxm
Date: 20/Jun/2022:11:43:34 +0000
URI: /coffee
Request ID: f91f15d1af17556e552557df2f5a0dd2
```


