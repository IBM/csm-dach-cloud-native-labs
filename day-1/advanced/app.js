const express = require("express");
const app = express();
const PORT = process.env.PORT || 8000;

app.get("/", (req, res) => {
  res.send("Hello from inside the container!");
});

app.listen(PORT, () => {
  console.log(`server listening on port ${PORT}!`);
});
