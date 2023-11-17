# Use an official Node runtime as a parent image
FROM node:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Install any needed packages
RUN npm install express jsonwebtoken

# Copy the rest of the application code
COPY jwt-auth-service/* .

# Make port 3000 available to the world outside this container
EXPOSE 5050

# Run authService.js when the container launches
CMD ["node", "authService.js"]
