FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN yarn install
COPY . .
RUN yarn build

# Stage 2: Serve the built files with Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Add custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]