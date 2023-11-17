FROM node:latest

RUN npm install -g json-server
EXPOSE 3000
RUN apt-get install curl -y
ENTRYPOINT ["json-server"]
