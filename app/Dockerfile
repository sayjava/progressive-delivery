FROM node:16.1.0-slim

ARG version='v1'

ENV VERSION=${version}

WORKDIR /app
ADD package*.json ./
RUN npm install
ADD index.js ./
CMD [ "npm", "start"]