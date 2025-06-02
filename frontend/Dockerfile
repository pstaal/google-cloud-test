FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# basis container met google cloud sdk voor kopieren van bestanden
FROM google/cloud-sdk:alpine

WORKDIR /app

COPY --from=builder /app/dist /app/dist