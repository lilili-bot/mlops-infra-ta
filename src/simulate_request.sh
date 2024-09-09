#!/bin/bash
FASTAPI_SERVICE=http://0.0.0.0:80

# Function to perform GET request and print the status code
get_request() {
    i=$1
    response="$(curl -s -o /dev/null -w \"%{http_code}\" $FASTAPI_SERVICE/items/${i}?q=example)"
    echo "GET /items/${i} - Status: $response"
}

# Function to perform POST request and print the status code
post_request() {
    json_data=$1
    response="$(curl -s -o /dev/null -w \"%{http_code}\" -X POST $FASTAPI_SERVICE/items/ -H "Content-Type: application/json" -d "$json_data")"
    echo "POST /items/ - Status: $response"
}

# Get Requests
for i in 1 2 3 4 5; do
    get_request $i
    sleep 1
done

# Post Requests
post_request '{"name":"Item1", "price": 10.5}'
post_request '{"name":"Item2", "price": 23.0}'
post_request '{"name":"Item3", "price": 7.99}'