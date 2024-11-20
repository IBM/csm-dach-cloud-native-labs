var express = require('express');
app = express();

app.get('/', function (req, res) {
  res.send('Hello all! Hope you have fun and learn something new! This will be a new build.');
});

app.listen(8080, function () {
  console.log('Example app listening on port 8080!');
});
