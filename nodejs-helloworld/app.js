var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send('Hello world! This change is for the users. Who started a manual build.');
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});
