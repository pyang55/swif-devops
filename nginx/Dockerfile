FROM openresty/openresty:alpine-fat

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-jwt

# Copy NGINX and site configuration
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Copy Lua scripts
COPY nginx/rate_limiting.lua /usr/local/openresty/nginx/lua/rate_limiting.lua

# Expose ports
EXPOSE 80

# Run NGINX
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
