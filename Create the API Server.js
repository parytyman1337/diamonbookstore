const express = require('express');
const bodyParser = require('body-parser');
const sql = require('mssql');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON requests
app.use(bodyParser.json());

// Database connection configuration
const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        encrypt: true, // Use encryption
        trustServerCertificate: true // Change to false for production
    }
};

// Connect to the SQL Server database
sql.connect(dbConfig, (err) => {
    if (err) console.error("Database connection failed: ", err);
    else console.log("Connected to database");
});

// Start the server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
