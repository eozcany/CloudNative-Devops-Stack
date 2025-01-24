# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# A wildcard is used to copy package.json AND package-lock.json (when present)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the application files
COPY app.js ./

# Expose the port your app runs on
EXPOSE 3000

# Define the command to run your app
CMD [ "node", "app.js" ]
