# Build Vue SPA
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN yarn build

# basis container met google cloud sdk voor kopieren van bestanden
FROM google/cloud-sdk:alpine

WORKDIR /app

COPY --from=builder /app/dist /app/dist

CMD ["bash", "-c", "gcloud auth activate-service-account --key-file=/config/gcloud/application_default_credentials.json && gsutil -m rsync -r /app/dist gs://frontend-ctrllearning-bucket"]