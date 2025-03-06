import express, { Application } from "express";
import recipientRouter from "./routes/recipient.routes.js";
const app: Application = express();

app.use(express.json());

// Mount routes
app.use("/recipients", recipientRouter);

export default app;
