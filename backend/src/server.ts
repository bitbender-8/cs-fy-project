import express, { Application, Request, Response } from "express";

const app: Application = express();
const port = process.env.PORT || 3000;

let i = 0;

app.get("/", (req: Request, res: Response) => {
  res.send("Express + TypeScript Server");
});

app.listen(port, () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);
});
