import express, { Application } from "express";
import helmet from "helmet";
import cors from "cors";

import { errorHandler } from "./errors/error-handlers.js";
import { campaignRouter } from "./routes/campaign.routes.js";
import { config } from "./config.js";
import { recipientRouter } from "./routes/recipient.routes.js";
import { supervisorRouter } from "./routes/supervisor.routes.js";
import { campaignRequestRouter } from "./routes/campaign-request.routes.js";
import { notificationRouter } from "./routes/notification.routes.js";
import { campaignPostRouter } from "./routes/campaign-post.routes.js";
import { ProblemDetails } from "./errors/error.types.js";
import { fileRouter } from "./routes/file.routes.js";

const app: Application = express();

app.use(helmet()); // Sets headers for better security

if (config.ENV === "Development") {
  app.use(cors());
}

app.use(express.json());

// Mount routes
app.use("/campaigns", campaignRouter);
app.use("/recipients", recipientRouter);
app.use("/supervisors", supervisorRouter);
app.use("/campaign-requests", campaignRequestRouter);
app.use("/notifications", notificationRouter);
app.use("/campaign-posts", campaignPostRouter);
app.use("/files", fileRouter);

// Error handlers
app.use(errorHandler);
app.use((req, res) => {
  const problemDetails: ProblemDetails = {
    title: "Not Found",
    status: 404,
    detail: `Cannot ${req.method} ${req.originalUrl}`,
  };
  res.status(problemDetails.status).json(problemDetails);
  return;
});

// Start server
app.listen(config.PORT, () => {
  console.log(`[server]: Server is running at http://localhost:${config.PORT}`);
});
