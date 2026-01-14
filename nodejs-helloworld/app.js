var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send('Hello world! Now with a Webhook. This time for you.');
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});
