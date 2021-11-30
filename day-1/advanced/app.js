const express = require("express");
app = express();
const PORT = 8000 || process.env.PORT;

app.get("/", (req, res) => {
  res.send("Hello from inside the container!");
});

app.listen(PORT, () => {
  console.log(`server listening on port ${PORT}!`);
});
