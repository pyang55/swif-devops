#!/bin/bash

# Endpoint URLs
CREATE_TOKEN_URL="http://localhost/create-token"
POSTS_URL="http://localhost/posts"

# User credentials
USERNAME="jane_doe"
PASSWORD="1234"

# JSON data
data="{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}"

# Content type
content_type="Content-Type: application/json"

# Number of requests to send
request_count=13

# Counters for responses
success_count=0
rate_limit_count=0

# Function to obtain JWT token
get_jwt_token() {
    RESPONSE=$(curl -s -X POST -H "$content_type" -d "$data" "$CREATE_TOKEN_URL")
    TOKEN=$(echo $RESPONSE | jq -r '.token')
    echo $TOKEN
}

# Main execution
TOKEN=$(get_jwt_token)
if [ -z "$TOKEN" ]; then
    echo "Failed to obtain token"
    exit 1
fi

# Loop to make requests
for ((i=1; i<=request_count; i++))
do
    # Make the HTTP GET request and capture the HTTP status code
    status_code=$(curl -X GET -H "Authorization: Bearer $TOKEN" -H "$content_type" -o /dev/null -s -w "%{http_code}\n" "$POSTS_URL")
    if [ "$status_code" == "200" ]; then
        ((success_count++))
    elif [ "$status_code" == "429" ]; then
        ((rate_limit_count++))
    fi
    echo "Request $i: HTTP Status $status_code"
done

echo "Successful requests: $success_count"
echo "Rate limited requests: $rate_limit_count"

