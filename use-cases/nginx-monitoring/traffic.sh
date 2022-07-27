#!/bin/bash
## This script creates sample traffic

clear
echo "Traffic generation started"
echo

for i in {1..700};
    do
        curl  --resolve app1.nginx.local:80:10.1.10.40 http://app1.nginx.local`shuf -n 1 ./urls.txt`
        curl  --resolve app2.nginx.local:80:10.1.10.40 http://app1.nginx.local`shuf -n 1 ./urls.txt`
        curl  --resolve app3.nginx.local:80:10.1.10.40 http://app1.nginx.local`shuf -n 1 ./urls.txt`
        curl  --resolve readiness.nginx.local:80:10.1.10.40 http://readiness.nginx.local`shuf -n 1 ./urls.txt`
        curl  --resolve echo.nginx.local:80:10.1.10.40 http://readiness.nginx.local`shuf -n 1 ./urls.txt`
    done


echo "Traffic generation finished"
echo