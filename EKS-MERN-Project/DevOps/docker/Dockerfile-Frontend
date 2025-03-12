# Stage 1: Build the application using Node.js
FROM node:21-alpine3.17 as build
WORKDIR /app
COPY . .
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm install
RUN npm update
RUN npm run build

# Stage 2: Run the application
FROM node:21-alpine3.17
WORKDIR /app
COPY --from=build /app /app
ENV NODE_OPTIONS=--openssl-legacy-provider
CMD ["npm", "start"]
