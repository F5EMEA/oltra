#!/bin/bash
## This script creates sample traffic

# Check if an IP address argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <ip_address>"
    exit 1
fi

# Clear the terminal screen
clear
# Display a message indicating the start of traffic generation
echo "Traffic generation started"
echo

# Check if ips.txt and urls.txt files exist and are readable
if [ ! -r "ips.txt" ] || [ ! -r "urls.txt" ]; then
    echo "Error: Required files (ips.txt or urls.txt) not found or not readable."
    exit 1
fi

clear
echo "Traffic generation started"
echo

for i in {1..700};
do
    ip=$(shuf -n 1 ./ips.txt)
    url=$(shuf -n 1 ./urls.txt)
    ua=$(shuf -n 1 ./user-agent.txt)
    name=$(shuf -n 1 ./parameter_names.txt)
    value=$(shuf -n 1 ./parameter_values.txt)
    #echo $value
    response=$(curl -sS http://$1$url -H "X-Forwarded-For: $ip" -H "User-Agent: $ua"  -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "$name=$value" )
    
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction $i - Blocked"
    else
        echo "Transaction $i - Pass"
    fi
done

echo "Traffic generation finished"
echo