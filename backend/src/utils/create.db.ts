import pg from "pg";
import fs from "fs";
import { config } from "../config.js";

const dbConfig = {
  user: config.DB_USER,
  password: config.DB_PASSWORD,
  host: config.DB_HOST,
  port: config.DB_PORT,
  database: "postgres", // Connect to the 'postgres' database initially
};

// Create a new PostgreSQL client
const client = new pg.Client(dbConfig);

// Connect to the database
client
  .connect()
  .then(() => {
    console.log("Connected to PostgreSQL database");

    const dbName = config.DB_NAME;
    const forceDrop = true; // Force drop enabled

    // Drop the database if it exists and forceDrop is true
    if (forceDrop) {
      client
        .query(`DROP DATABASE IF EXISTS "${dbName}" WITH (FORCE);`) // use force drop
        .then(() => {
          console.log(`Database ${dbName} forcefully dropped if it existed`);

          // Create the database
          client
            .query(`CREATE DATABASE "${dbName}";`)
            .then(() => {
              console.log(`Database "${dbName}" created successfully`);
              // Connect to the newly created database to create tables
              client.end(); // close the current connection

              const newClient = new pg.Client({
                ...dbConfig,
                database: dbName,
              });
              newClient
                .connect()
                .then(() => {
                  createTables(newClient); // call function to create tables
                })
                .catch((err) => {
                  console.error("Error connecting to new database", err);
                });
            })
            .catch((err) => {
              if (err.code === "42P04") {
                console.log(`Database "${dbName}" already exists`);
                client.end(); // close the current connection

                const newClient = new pg.Client({
                  ...dbConfig,
                  database: dbName,
                });
                newClient
                  .connect()
                  .then(() => {
                    createTables(newClient); // call function to create tables
                  })
                  .catch((err) => {
                    console.error("Error connecting to new database", err);
                  });
              } else {
                console.error(`Error creating database "${dbName}":`, err);
                client.end();
              }
            });
        })
        .catch((err) => {
          console.error(`Error forcefully dropping database "${dbName}":`, err);
          client.end();
        });
    } else {
      client
        .query(`DROP DATABASE IF EXISTS "${dbName}";`)
        .then(() => {
          console.log(`Database ${dbName} dropped if it existed`);

          // Create the database
          client
            .query(`CREATE DATABASE "${dbName}";`)
            .then(() => {
              console.log(`Database "${dbName}" created successfully`);
              client.end(); // close the current connection
              const newClient = new pg.Client({
                ...dbConfig,
                database: dbName,
              }); //create new client with new database name
              newClient
                .connect()
                .then(() => {
                  createTables(newClient); // call function to create tables
                })
                .catch((err) => {
                  console.error("Error connecting to new database", err);
                });
            })
            .catch((err) => {
              if (err.code === "42P04") {
                console.log(`Database "${dbName}" already exists`);
                client.end(); // close the current connection
                const newClient = new pg.Client({
                  ...dbConfig,
                  database: dbName,
                }); //create new client with new database name
                newClient
                  .connect()
                  .then(() => {
                    createTables(newClient); // call function to create tables
                  })
                  .catch((err) => {
                    console.error("Error connecting to new database", err);
                  });
              } else {
                console.error(`Error creating database "${dbName}":`, err);
                client.end();
              }
            });
        })
        .catch((err) => {
          console.error(`Error dropping database "${dbName}":`, err);
          client.end();
        });
    }
  })
  .catch((err) => {
    console.error("Error connecting to PostgreSQL database", err);
  });

function createTables(client: pg.Client) {
  fs.readFile("./db/schema.sql", "utf8", (err, sql) => {
    if (err) {
      console.error("Error reading SQL file:", err);
      client.end();
      return;
    }
    client
      .query(sql)
      .then(() => {
        console.log("Tables created successfully");
        client.end();
      })
      .catch((err) => {
        console.error("Error creating tables:", err);
        client.end();
      });
  });
}
