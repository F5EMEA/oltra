#!/bin/bash
## This script creates sample traffic

clear
echo "Traffic generation started"
echo

for i in {1..700};
    do
        curl http://`shuf -n 1 ./ips.txt``shuf -n 1 ./urls.txt`
        curl http://`shuf -n 1 ./ips.txt``shuf -n 1 ./urls.txt`
        curl http://`shuf -n 1 ./ips.txt``shuf -n 1 ./urls.txt`
        curl http://`shuf -n 1 ./ips.txt``shuf -n 1 ./urls.txt`
        curl -k --resolve reencrypt.f5demo.local:443:10.1.10.69 https://reencrypt.f5demo.local`shuf -n 1 ./urls.txt`
        curl -k --resolve reencrypt.f5demo.local:443:10.1.10.69 https://reencrypt.f5demo.local`shuf -n 1 ./urls.txt`
        curl -k --resolve reencrypt.f5demo.local:443:10.1.10.69 https://reencrypt.f5demo.local`shuf -n 1 ./urls.txt`
        curl -k --resolve reencrypt.f5demo.local:443:10.1.10.69 https://reencrypt.f5demo.local`shuf -n 1 ./urls.txt`
        curl --tlsv1.0 --tls-max 1.0 -k  --ciphers CAMELLIA256-SHA --resolve reencrypt.f5demo.local:443:10.1.10.69 https://reencrypt.f5demo.local`shuf -n 1 ./urls.txt`        
        curl  --resolve policy.f5demo.local:80:10.1.10.66 http://policy.f5demo.local`shuf -n 1 ./urls.txt`
        curl  --resolve policy.f5demo.local:80:10.1.10.66 http://policy.f5demo.local`shuf -n 1 ./urls.txt`
        curl  --resolve readiness.f5demo.local:80:10.1.10.83 http://readiness.f5demo.local`shuf -n 1 ./urls.txt`
    done


echo "Traffic generation finished"
echo