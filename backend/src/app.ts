import express, { Application } from "express";
const app: Application = express();

app.use(express.json());

// Mount routes

export default app;
