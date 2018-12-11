const http = require('http');
const figlet = require("figlet");
const port = process.env.PORT || 3000;

const handler = (req, res) => {
    console.log('Server received request.');
    message = 'Hello World';
    figlet(message, (err, data) => {
      if (err) {
            console.log('Something went wrong... ');
            console.dir(err);
            return;
    }
    res.end(data);
    });
    console.log('Server returned response.');
};

const server = http.createServer(handler);

server.listen(port, err => {
    if (err) {
        console.log(err);
    }
    else {
        console.log(`Server listening on port: ${port}`);
    }
});