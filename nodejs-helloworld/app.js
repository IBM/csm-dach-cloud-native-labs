var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send('Hello world! This time the message comes from command line.');
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});
