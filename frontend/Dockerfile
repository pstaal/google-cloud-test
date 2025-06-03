FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN yarn install
COPY . .
RUN yarn build

# basis container met google cloud sdk voor kopieren van bestanden
FROM google/cloud-sdk:alpine

WORKDIR /app

COPY --from=builder /app/dist /app/dist

CMD ["gsutil", "-m", "rsync", "-r", "/app/dist", "gs://frontend-ctrllearning-bucket"]