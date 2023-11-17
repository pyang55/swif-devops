#!/bin/bash

# Endpoint to be tested
url="http://localhost/create-token"

# JSON data
data='{"username":"john_doe","password":"1234"}'

# Content type
content_type="Content-Type: application/json"

# Number of requests to send
request_count=20

# Counters for responses
success_count=0
rate_limit_count=0

for ((i=1; i<=request_count; i++))
do
    # Make the HTTP POST request and capture the HTTP status code
    status_code=$(curl -X POST -H "$content_type" -d "$data" -o /dev/null -s -w "%{http_code}\n" $url)

    if [ "$status_code" == "200" ]; then
        ((success_count++))
    elif [ "$status_code" == "429" ]; then
        ((rate_limit_count++))
    fi

    echo "Request $i: HTTP Status $status_code"
done

echo "Successful requests: $success_count"
echo "Rate limited requests: $rate_limit_count"

