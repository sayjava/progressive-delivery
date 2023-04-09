FROM node:16.1.0-slim
WORKDIR /app
ADD package*.json ./
RUN npm install
ADD index.js ./
CMD [ "npm", "start"]