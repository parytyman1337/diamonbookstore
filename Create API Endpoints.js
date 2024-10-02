// Get all books
app.get('/api/books', async (req, res) => {
    try {
        const request = new sql.Request();
        const result = await request.query('SELECT * FROM Books');
        res.status(200).json(result.recordset);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching books', error: err });
    }
});

// Get a specific book by ID
app.get('/api/books/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        const result = await request.input('id', sql.Int, id).query('SELECT * FROM Books WHERE book_id = @id');
        res.status(200).json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching book', error: err });
    }
});

// Add a new book
app.post('/api/books', async (req, res) => {
    const { title, author, isbn, description, price, category_id } = req.body;
    try {
        const request = new sql.Request();
        await request
            .input('title', sql.VarChar, title)
            .input('author', sql.VarChar, author)
            .input('isbn', sql.VarChar, isbn)
            .input('description', sql.VarChar, description)
            .input('price', sql.Decimal(10, 2), price)
            .input('category_id', sql.Int, category_id)
            .query('INSERT INTO Books (title, author, isbn, description, price, category_id) VALUES (@title, @author, @isbn, @description, @price, @category_id)');
        res.status(201).json({ message: 'Book added successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error adding book', error: err });
    }
});

// Update a book
app.put('/api/books/:id', async (req, res) => {
    const { id } = req.params;
    const { title, author, isbn, description, price, category_id } = req.body;
    try {
        const request = new sql.Request();
        await request
            .input('id', sql.Int, id)
            .input('title', sql.VarChar, title)
            .input('author', sql.VarChar, author)
            .input('isbn', sql.VarChar, isbn)
            .input('description', sql.VarChar, description)
            .input('price', sql.Decimal(10, 2), price)
            .input('category_id', sql.Int, category_id)
            .query('UPDATE Books SET title = @title, author = @author, isbn = @isbn, description = @description, price = @price, category_id = @category_id WHERE book_id = @id');
        res.status(200).json({ message: 'Book updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating book', error: err });
    }
});

// Delete a book
app.delete('/api/books/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        await request.input('id', sql.Int, id).query('DELETE FROM Books WHERE book_id = @id');
        res.status(200).json({ message: 'Book deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting book', error: err });
    }
});



const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// User login and JWT token generation
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const request = new sql.Request();
        const result = await request.input('email', sql.VarChar, email).query('SELECT * FROM Customers WHERE email = @email');
        const user = result.recordset[0];
        if (!user || !bcrypt.compareSync(password, user.password)) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        const token = jwt.sign({ id: user.customer_id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.status(200).json({ token });
    } catch (err) {
        res.status(500).json({ message: 'Error logging in', error: err });
    }
});

// Middleware to protect routes
const authenticateJWT = (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) return res.status(403).send('Access denied.');

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        res.status(400).send('Invalid token.');
    }
};
