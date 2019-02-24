mongo tailwind --eval "db.dropUser('REPLACEDROPUSERNAME')"
mongo tailwind --eval "db.createUser({user:'REPLACECREATEUSERNAME',pwd:'REPLACEPASSWORD',roles:[{role:'dbAdmin',db:'tailwind'}]})"
