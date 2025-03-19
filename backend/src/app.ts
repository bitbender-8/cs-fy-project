import express, { Application } from "express";
import helmet from "helmet";
import { errorHandler } from "./errors/error-handlers.js";
import { jwtCheck } from "./middleware/auth.middleware.js";
import { campaignRouter } from "./routes/campaign.routes.js";
import { config } from "./config.js";

const app: Application = express();

app.use(helmet()); // Sets headers for better security

if (config.ENV === "Development") {
  app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header(
      "Access-Control-Allow-Headers",
      "Origin, X-Requested-With, Content-Type, Accept"
    );
    next();
  });
}

app.use(express.json());

// Auth
app.use(jwtCheck);

// Mount routes
app.use("/campaigns", campaignRouter);

// Error handlers
app.use(errorHandler);

// Start server
app.listen(config.PORT, () => {
  console.log(`[server]: Server is running at http://localhost:${config.PORT}`);
});
