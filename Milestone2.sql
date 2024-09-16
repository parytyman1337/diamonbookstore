-- Insert categories (using a robust check to avoid duplicates)
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Categories WHERE name = 'Fiction')
    INSERT INTO Categories (name, parent_category_id) VALUES ('Fiction', NULL);

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE name = 'Non-Fiction')
    INSERT INTO Categories (name, parent_category_id) VALUES ('Non-Fiction', NULL);

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE name = 'Science Fiction')
    INSERT INTO Categories (name, parent_category_id) VALUES ('Science Fiction', 1);

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE name = 'Fantasy')
    INSERT INTO Categories (name, parent_category_id) VALUES ('Fantasy', 1);

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE name = 'Biography')
    INSERT INTO Categories (name, parent_category_id) VALUES ('Biography', 2);

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE name = 'Self-help')
    INSERT INTO Categories (name, parent_category_id) VALUES ('Self-help', 2);
END TRY
BEGIN CATCH
    PRINT 'Error occurred while inserting categories: ' + ERROR_MESSAGE();
END CATCH;

-- Insert books (checking for duplicates based on ISBN)
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Books WHERE isbn = '9780441013593')
    INSERT INTO Books (title, author, isbn, description, price, currency, publication_date, publisher, stock_quantity, category_id, language, format)
    VALUES ('Dune', 'Frank Herbert', '9780441013593', 'Science fiction novel set in a distant future', 9.99, 'USD', '1965-08-01', 'Chilton Books', 100, 3, 'English', 'Paperback');

    IF NOT EXISTS (SELECT 1 FROM Books WHERE isbn = '9780618968633')
    INSERT INTO Books (title, author, isbn, description, price, currency, publication_date, publisher, stock_quantity, category_id, language, format)
    VALUES ('The Hobbit', 'J.R.R. Tolkien', '9780618968633', 'Fantasy novel about the adventures of Bilbo Baggins', 14.99, 'USD', '1937-09-21', 'George Allen & Unwin', 50, 4, 'English', 'Hardcover');

    IF NOT EXISTS (SELECT 1 FROM Books WHERE isbn = '9781524763138')
    INSERT INTO Books (title, author, isbn, description, price, currency, publication_date, publisher, stock_quantity, category_id, language, format)
    VALUES ('Becoming', 'Michelle Obama', '9781524763138', 'Memoir of former First Lady of the United States', 19.99, 'USD', '2018-11-13', 'Crown Publishing Group', 80, 5, 'English', 'Hardcover');

    IF NOT EXISTS (SELECT 1 FROM Books WHERE isbn = '9780735211292')
    INSERT INTO Books (title, author, isbn, description, price, currency, publication_date, publisher, stock_quantity, category_id, language, format)
    VALUES ('Atomic Habits', 'James Clear', '9780735211292', 'Book about building good habits and breaking bad ones', 16.99, 'USD', '2018-10-16', 'Avery', 120, 6, 'English', 'Paperback');
END TRY
BEGIN CATCH
    PRINT 'Error occurred while inserting books: ' + ERROR_MESSAGE();
END CATCH;

-- Select all books
SELECT * FROM Books;

-- Select books in the 'Science Fiction' category (more robust with a valid category check)
IF EXISTS (SELECT 1 FROM Categories WHERE name = 'Science Fiction')
BEGIN
    SELECT b.title, b.author, b.price, c.name AS category
    FROM Books b
    JOIN Categories c ON b.category_id = c.category_id
    WHERE c.name = 'Science Fiction';
END
ELSE
    PRINT 'No category named Science Fiction exists.';

-- Select books priced under $15 (validating price range with proper error message)
BEGIN TRY
    SELECT title, author, price
    FROM Books
    WHERE price < 15;
END TRY
BEGIN CATCH
    PRINT 'Error occurred while selecting books: ' + ERROR_MESSAGE();
END CATCH;

-- Select book titles and stock quantities (ensuring stock quantity is positive)
SELECT title, stock_quantity
FROM Books
WHERE stock_quantity > 0;

-- Select books by Michelle Obama (checking for valid results)
IF EXISTS (SELECT 1 FROM Books WHERE author = 'Michelle Obama')
BEGIN
    SELECT title, isbn, price
    FROM Books
    WHERE author = 'Michelle Obama';
END
ELSE
    PRINT 'No books found by Michelle Obama.';

-- Count books in each category
SELECT c.name AS category, COUNT(b.book_id) AS book_count
FROM Books b
JOIN Categories c ON b.category_id = c.category_id
GROUP BY c.name;
