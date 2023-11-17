const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();

app.use(express.json());

//normally secret key will be kept in vault or some secrets k/v store
const secretKey = 'b1GsECRETkEYnOTfORpROD'; // Replace with a real secret key

// Middleware for logging each request
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    console.log('Headers:', req.headers);
    next();
});

app.post('/create-token', (req, res) => {
    console.log('Create Token Request Received:', new Date().toISOString());
    const userData = req.body; // In a real scenario, you'd validate these credentials
    const { username } = userData;
    if (!username) {
        return res.status(400).json({ message: "Username is required in the request body" });
    }
    const token = jwt.sign(userData, secretKey, { expiresIn: '1h' });

    // Set a custom header with the username
    res.setHeader('X-User-Name', username);
    res.json({ token });
});

// Endpoint to authenticate a token
app.get('/authenticate-token', (req, res) => {
    const authHeader = req.headers.authorization;
    console.log('Received Authorization Header:', authHeader);

    if (authHeader && authHeader.startsWith('Bearer ')) {
        const token = authHeader.substring(7).trim(); // Extract and trim the token
        console.log('Extracted Token:', token);

        try {
            const decoded = jwt.verify(token, secretKey);
            console.log("Token is valid");
            res.status(200).json({ message: "Authentication Successful", decoded });
        } catch (err) {
            console.log("Token is invalid");
            res.status(401).json({ message: "Authentication Failed" });
        }
    } else {
        console.log("Token is missing or invalid format");
        res.status(401).json({ message: "Authentication Failed: Token missing or invalid format" });
    }
});

const PORT = 5050;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Auth Service running on port ${PORT}`);
});
