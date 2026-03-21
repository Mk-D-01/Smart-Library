# Use Node.js 20 Alpine as base image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json for layer caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code (this will overwrite any cached files)
COPY . .

# Expose port 3000
EXPOSE 3000

# Command to run the development server with hot-reload
CMD ["npm", "run", "dev"]
