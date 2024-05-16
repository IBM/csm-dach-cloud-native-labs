var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send('Hello all! This time rebuilding on the console. With the Webhook in place.');
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});
