#!/bin/bash
## This script creates sample traffic

# Function to generate a random integer within a specified range
generate_random_int() {
    local min=$1
    local max=$2
    echo $(($(shuf -i $min-$max -n 1)))
}

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
echo "Traffic generation started for attack signatures and bot traffic"
echo

for i in {1..250};
do
    ip=$(shuf -n 1 ./ips.txt)
    url=$(shuf -n 1 ./urls.txt)
    ua=$(shuf -n 1 ./user-agent.txt)
    name=$(shuf -n 1 ./parameter_names.txt)
    value=$(shuf -n 1 ./parameter_values.txt)
    h_name=$(shuf -n 1 ./parameter_names.txt)
    h_value=$(shuf -n 1 ./parameter_values.txt)   
    #echo $value
    response=$(curl -sS http://$1$url -H "X-Forwarded-For: $ip" -H "User-Agent: $ua" -H "$h_name: $h_value" -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "$name=$value" )
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction $i - Blocked"
    else
        echo "Transaction $i - Pass"
    fi
done


## Cookie/HTTP Header Length
for i in {1..50};
do
    ip=$(shuf -n 1 ./ips.txt)
    url=$(shuf -n 1 ./urls.txt)
    ua=$(shuf -n 1 ./user-agent.txt)

    cookie_random_string=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 200)

    response=$(curl -sS http://$1$url -H "X-Forwarded-For: $ip" -H "User-Agent: $ua" -b "session_id=$cookie_random_string" )
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction Cookie Header violation $i - Blocked"
    else
        echo "Transaction Cookie Header violation $i - Pass"
    fi


    http_random_string=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 200)

    response=$(curl -sS http://$1$url -H "X-Forwarded-For: $ip" -H "User-Agent: $ua" -H "Referer=$http_random_string" )
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction HTTP Header violation $i - Blocked"
    else
        echo "Transaction HTTP Header violation $i - Pass"
    fi
done



## Parameter value violations
for i in {1..100};
do
    ip=$(shuf -n 1 ./ips.txt)
    url=$(shuf -n 1 ./urls.txt)
    ua=$(shuf -n 1 ./user-agent.txt)

    random_int=$(generate_random_int 1 50)

    response=$(curl -sS "http://$1$url?value=$random_int&user=&value=12&test_length=123123123&int_input=abc" -H "X-Forwarded-For: $ip" -H "User-Agent: $ua" )
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction Parameter violations $i - Blocked"
    else
        echo "Transaction Parameter violations $i - Pass"
    fi



done

# Method violation
for i in {1..50};
do
    ip=$(shuf -n 1 ./ips.txt)
    url=$(shuf -n 1 ./urls.txt)
    ua=$(shuf -n 1 ./user-agent.txt)
    method=$(shuf -n 1 ./methods.txt)

    response=$(curl -sS http://$1$url -H "X-Forwarded-For: $ip" -H "User-Agent: $ua" -X $method )
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction Method violation $i - Blocked"
    else
        echo "Transaction Method violation $i - Pass"
    fi

done


# Cookie Modified violation
for i in {1..10};
do
    ip=$(shuf -n 1 ./ips.txt)
    url=$(shuf -n 1 ./urls.txt)
    ua=$(shuf -n 1 ./user-agent.txt)

    cookie_random_string=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 5)

    response=$(curl -sS http://$1$url -H "X-Forwarded-For: $ip" -H "User-Agent: $ua" -b "session=$cookie_random_string" )
    
    # Check if the response contains the keyword
    if [[ $response =~ "support ID" ]]; then
        echo "Transaction Cookie Modified violation $i - Blocked"
    else
        echo "Transaction Cookie Modified violation $i - Pass"
    fi

done



echo "Traffic generation finished"
echo

