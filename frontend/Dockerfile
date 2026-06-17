# FROM node:16-alpine
# WORKDIR /frontend
# COPY package.json ./
# RUN npm install
# COPY . ./
# EXPOSE 3000
# ENV CI=true
# ENV CHOKIDAR_USEPOLLING=true
# ENV HOST=0.0.0.0
# CMD ["npm", "start"]
FROM node:16-alpine

WORKDIR /frontend

COPY package.json ./
RUN npm install

COPY . ./

# build production app
RUN npm run build

# serve build using simple static server
RUN npm install -g serve

EXPOSE 80

CMD ["serve", "-s", "build", "-l", "80"]