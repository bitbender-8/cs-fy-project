# Connecting to PostgreSQL Database in pgAdmin4

**Note:** Before proceeding, ensure you've run `docker-compose up` in the directory containing your `docker-compose.yml` file to create and start the PostgreSQL and pgAdmin4 containers. If you've done this before, all you need to do to start them up again is run `docker-compose start` while in the `/backend` directory. Also be aware that this version of `docker-compose.yml` only sets up the database and pgAdmin4; it doesn't start the backend server.

To connect to the database in pgAdmin4 using the provided `docker-compose.yml` file, follow these steps:

1. Open your web browser and navigate to `http://localhost:8080`.
2. Log in to pgAdmin4: Use the email and password specified in the `docker-compose.yml` file for the pgAdmin service:
   - **Email**: `email@example.com`
   - **Password**: `StrongPassword`
3. In the pgAdmin4 interface, add a new server connection:
   - Right-click on the "Servers" option.
   - Select the "Register" option to add a new server.
4. In the "General" menu, specify the name of the server (e.g., "tesfafund-db"). Then, set the hostname or address, port, username, and password in the "Connection" menu:
   - **Host name/address**: `tesfafund-db` (This is the name of the PostgreSQL service in `docker-compose.yml`. Docker uses service names as hostnames within the Docker network).
   - **Port**: `5432` (the default PostgreSQL port inside the container).
   - **Username**: `admin` (specified as `POSTGRES_USER` in the `docker-compose.yml` file).
   - **Password**: `StrongPassword` (specified as `POSTGRES_PASSWORD` in the `docker-compose.yml` file).
5. Click the "Save" button to save the connection
   - Once you save the connection, pgAdmin4 should connect to the PostgreSQL database. You can then use pgAdmin4 to manage the `tesfafund-db` database.
6. Under Servers/tesfafund-db/Databases, right click on Databases and create the database `TesfaFundDB`. All you have to provide is the name.
