# Gebruik Node.js v22.6.0 als de basisimage
FROM node:22.6.0

# Stel de werkdirectory in voor de container
WORKDIR /backend

# Kopieer package.json en yarn.lock voor dependencies
COPY package.json yarn.lock ./

RUN corepack enable

# Installeer dependencies
RUN yarn install

# Kopieer de rest van de applicatiecode naar de container
COPY ./backend /backend

# Stel het standaardcommando in om de applicatie te starten
CMD ["yarn", "serve"]