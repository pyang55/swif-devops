# Project Name

## Quick Links
- [Overview](#overview)
- [Components](#components)
  - [Docker Containers](#docker-containers)
  - [Configuration Files](#configuration-files)
- [Setup and Deployment](#setup-and-deployment)
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)
- [Configuration Adjustments](#configuration-adjustments)
- [Testing Rate Limit Settings](#testing-rate-limit-settings)
  - [Overview](#overview-1)
  - [Running the Scripts](#running-the-scripts)
  - [Expected Output](#expected-output)
- [Assumptions](#assumptions)

## Overview

This project sets up a robust API server architecture using Docker. It includes an API server, an authentication service, and is fronted by Nginx for efficient request handling and security. The setup allows for easy scalability and maintainability.

## Components

### Docker Containers
- **API Server**: Defined in `jsonserver.Dockerfile`. This container runs the main application. We are using https://github.com/typicode/json-server. Useful for mock APIs or additional services. All the endpoints can be found https://jsonplaceholder.typicode.com/db 
- **Auth Server**: Specified in `jwt-auth-service/Dockerfile`. A script written by me to use as an authentication piece to return a JWT token.
- **Nginx**: Configured in `nginx.conf`. It acts as a reverse proxy, directing traffic to appropriate services.

### Configuration Files
- **docker-compose.yaml**: Orchestrates the multi-container setup, ensuring smooth interaction between services.
- **nginx.conf**: Nginx configuration for request handling, load balancing, and more.
- **rate_limiting.lua**: Lua script for Nginx to implement rate limiting, protecting the server from excessive requests.

## Setup and Deployment

### Prerequisites
- Docker and Docker Compose installed on your system.

### Steps

1. **Build and Start the Containers**
   - To build and start the containers as defined in your `docker-compose.yaml` file, use the following command:
     ```
     docker-compose up -d --no-deps --build
     ```
   - This command will start all your services in detached mode, running them in the background.

2. **Stopping Services**
   - To stop all services, you can use:
     ```
     docker-compose down
     ```

### Configuration Adjustments

1. **Changing Rate Limits**
   - Edit `rate_limiting.lua` with your desired limits.
   - Restart Nginx to apply changes using:
     ```
     docker-compose restart nginx
     ```

2. **Adding Users for Rate Limiting**
   - Update the user list in the appropriate section of your configuration file.
    ```
    john_doe = { rate = 5, burst = 10 },
    new_username = { rate = x, burst = y },
    ```
   - Restart the relevant services for changes to take effect:
     ```
     docker-compose restart nginx
     ```

## Testing Rate Limit Settings

### Overview
- Three scripts are provided to test the rate limiting settings of your API: `create-endpoint.sh`, `user-john-ratelimit.sh`, and `user-jane-ratelimit.sh`.

### Running the Scripts

1. **Testing by curl commands**
    The create-token creates a JWT token that is then sent to all further requests down the line for authentication
    ```
    curl -X POST http://localhost/create-token -H "Content-Type: application/json" -d '{"username":"test_user","password":"1234"}'

    curl -X GET http://localhost/posts -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6ImpvaG5fZG9lIiwicGFzc3dvcmQiOiIxMjM0IiwiaWF0IjoxNzAwMTYyNTAyLCJleHAiOjE3MDAxNjYxMDJ9.wB9rBo6_kbNmmXBeC8uLILT8Swrr-FUwAuDA5EiRoUo"
    ```

2. **Executing create-endpoint.sh**
   - Make the script executable:
     ```
     chmod +x create-endpoint.sh
     ```
   - Run the script:
     ```
     ./create-endpoint.sh
     ```

3. **Executing user-john-ratelimit.sh**
   - Ensure `jq` is installed for JSON parsing.
   - Make the script executable:
     ```
     chmod +x user-john-ratelimit.sh
     ```
   - Run the script:
     ```
     ./user-john-ratelimit.sh
     ```

4. **Executing user-jane-ratelimit.sh (after adding jane_doe user to rate_limiting.lua)**
   - Ensure `jq` is installed for JSON parsing.
   - Make the script executable:
     ```
     chmod +x user-jane-ratelimit.sh
     ```
   - Run the script:
     ```
     ./user-jane-ratelimit.sh
     ```

### Expected Output
- The scripts will output the number of successful and rate-limited requests, helping in validating the rate limiting configuration.

## Assumptions
There are a few assumptions made in the making of this project and there are a few things i would do differently
- The assumption here (and how it would normally be in production) is that we want specific public endpoints to have default rate limits and we can add and adjust separate rate limits to other endpoints that users have to authenticate to. 
- In production nginx confs would be handled by consul template so that everything would be dynamic for different routes
- I would not hard code the auth token, but for the sake of this exercise, no need to implement a secrets manager
- I might use traefik instead of nginx, more robust.
- I also chose to reject the calls instead of throttle to the rate I set. We can do that easily in rate_limiting.lua with an extra delay. But in order to show that we are rate limiting at different rates, this was easiest way to show