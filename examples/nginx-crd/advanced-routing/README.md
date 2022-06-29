# Advanced Routing

In this example we use the [VirtualServer](https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/) resource to configure advanced routing for the cafe application from the [Basic Configuration](../basic-configuration/) example, for which we have introduced the following changes:
* Instead of one version of the tea service, we have two: `tea-post-svc` and `tea-svc`. We send POST requests for tea to `tea-post-svc` and non-POST requests, such as GET requests, to `tea-svc`.
* Instead of one version of the coffee service, we have two: `coffee-v1-svc` and `coffee-v2-svc`. We send requests that include the cookie `version` set to `v2` to `coffee-v2-svc` and all other requests to `coffee-v1-svc`.
* To simplify the example, we have removed TLS termination.


## Step 1 - Configure Load Balancing

Create the VirtualServer resource:
```
$ kubectl apply -f routing-virtual-server.yaml
```

## Step 2 - Test the Configuration

1. Check that the configuration has been successfully applied by inspecting the events of the VirtualServer:
    ```
    $ kubectl describe virtualserver cafe
    . . .
    Events:
      Type    Reason          Age   From                      Message
      ----    ------          ----  ----                      -------
      Normal  AddedOrUpdated  2s    nginx-ingress-controller  Configuration for default/cafe was added or updated
    ```
1. Access the tea service using curl. We'll use curl's `--resolve` option to set the IP address and HTTP port of the Ingress Controller to the domain name of the cafe application:
    
    Send a POST request and confirm that the response comes from `tea-post-svc`:
    ```
    $ curl --resolve routing.f5demo.local:80:10.1.10.40 http://routing.f5demo.local/tea -X POST
    Server address: 10.16.1.188:80
    Server name: tea-post-b5dd479b4-6ssmh
    . . .
    ```

    Send a GET request and confirm that the response comes from `tea-svc`:
    ```
    $ curl --resolve routing.f5demo.local:80:10.1.10.40 http://routing.f5demo.local/tea
    Server address: 10.16.1.189:80
    Server name: tea-7d57856c44-2hsvr
    . . .
    ```

1.  Access the coffee service:
    
    Send a request with the cookie `version=v2` and confirm that the response comes from `coffee-v2-svc`:
    ```
    $ curl --resolve routing.f5demo.local:80:10.1.10.40 http://routing.f5demo.local/coffee --cookie "version=v2"
    Server address: 10.16.1.187:80
    Server name: coffee-v2-7fd446968b-vkthp
    . . .
    ```

    Send a request without the cookie and confirm that the response comes from `coffee-v1-svc`:
    ```
    $ curl --resolve routing.f5demo.local:80:10.1.10.40 http://routing.f5demo.local/coffee
    Server address: 10.16.0.153:80
    Server name: coffee-v1-78754bdcfb-bs9nh
    . . .
    ```