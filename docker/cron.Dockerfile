from node:latest

workdir /app

copy package*.json .
run npm install
copy . .

cmd ["node", "cron.js"]
