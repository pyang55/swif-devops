local limit_req = require "resty.limit.req"

-- User-specific rate limit configurations
local user_rate_limits = {
    john_doe = { rate = 5, burst = 10 },
    -- Add new users here in the following format:
    -- ["username"] = { rate = x, burst = y },
}

-- Default rate limit configuration
local default_rate = 10
local default_burst = 10

-- Function to create a rate limit object
local function create_rate_limit(rate, burst)
    local limit, err = limit_req.new("my_limit_store", rate, burst)
    if not limit then
        ngx.log(ngx.ERR, "Failed to instantiate rate limit: ", err)
        return nil
    end
    return limit
end

-- Create a table to store rate limit objects for each user
local rate_limits = {}
for username, limits in pairs(user_rate_limits) do
    rate_limits[username] = create_rate_limit(limits.rate, limits.burst)
end

-- Create default limit
local default_limit = create_rate_limit(default_rate, default_burst)

-- Function to extract JWT token from the Authorization header
local function extract_token()
    local auth_header = ngx.var.http_authorization
    if not auth_header then
        ngx.log(ngx.ERR, "No Authorization header")
        return nil
    end

    local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
    return token
end

-- Function to decode JWT token
local function decode_jwt(token)
    local jwt = require "resty.jwt"

    -- normally secret key will be kept in vault or some secrets k/v store
    local verified_jwt = jwt:verify("b1GsECRETkEYnOTfORpROD", token)
    if not verified_jwt or not verified_jwt.verified then
        ngx.log(ngx.ERR, "Invalid JWT Token")
        return nil
    end
    return verified_jwt
end

-- Main rate limiting function
local function rate_limiting()
    local token = extract_token()
    local key
    local limit = default_limit

    if token then
        local decoded = decode_jwt(token)
        if decoded and decoded.payload and decoded.payload.username then
            key = decoded.payload.username
            if rate_limits[key] then
                limit = rate_limits[key]
            end
        end
    end
    
    if not key then
        key = ngx.var.remote_addr
    end

    local delay, err = limit:incoming(key, true)

    if err == "rejected" then
        ngx.status = 429
        ngx.say("Rate limit exceeded")
        ngx.exit(ngx.HTTP_TOO_MANY_REQUESTS)
    end

    -- Continue with the request processing if not rejected
end

-- Apply the rate limiting
rate_limiting()
