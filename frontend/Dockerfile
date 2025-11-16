FROM node:lts-alpine

# set the working directory
WORKDIR /app

# copy package files
COPY package*.json ./

# install app dependencies
RUN npm install
RUN npm install -g serve

# Bundle app source
COPY . ./

RUN chown -R node:node /app/node_modules || true

# start app
CMD ["npm", "run", "dev"]