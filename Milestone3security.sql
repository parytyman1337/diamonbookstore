-- 1. Skip creation of api_user since it already exists

-- 2. Data Encryption Setup

-- First, create a database master key if it doesn't already exist
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKeyPassword123!';
END;
GO

-- Create a certificate for encryption if it doesn't already exist
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'MyCertificate')
BEGIN
    CREATE CERTIFICATE MyCertificate
    WITH SUBJECT = 'Certificate for Data Encryption';
END;
GO

-- Create a symmetric key for encryption if it doesn't already exist
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'MySymmetricKey')
BEGIN
    CREATE SYMMETRIC KEY MySymmetricKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE MyCertificate;
END;
GO

-- Open the symmetric key for use
OPEN SYMMETRIC KEY MySymmetricKey DECRYPTION BY CERTIFICATE MyCertificate;

-- Add the encrypted_email column if it doesn't already exist
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE Name = N'encrypted_email' AND Object_ID = Object_ID(N'Customers')
)
BEGIN
    ALTER TABLE Customers
    ADD encrypted_email VARBINARY(MAX);
END;

-- Encrypt the email addresses in the Customers table
UPDATE Customers
SET encrypted_email = ENCRYPTBYKEY(KEY_GUID('MySymmetricKey'), CAST(email AS VARCHAR(255)));

-- Close the symmetric key after use
CLOSE SYMMETRIC KEY MySymmetricKey;
GO

-- 3. Stored Procedures, Auditing, and Logging (remains unchanged from the previous script)

-- Drop and recreate the GetBooksByCategory stored procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetBooksByCategory')
BEGIN
    DROP PROCEDURE GetBooksByCategory;
END;
GO

CREATE PROCEDURE GetBooksByCategory
    @CategoryID INT
AS
BEGIN
    IF @CategoryID IS NULL
    BEGIN
        PRINT 'Category ID is required';
        RETURN;
    END

    SELECT * FROM Books WHERE category_id = @CategoryID;
END;
GO

-- Drop and recreate the AddBook stored procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'AddBook')
BEGIN
    DROP PROCEDURE AddBook;
END;
GO

CREATE PROCEDURE AddBook
    @Title VARCHAR(255),
    @Price DECIMAL(10, 2),
    @CategoryID INT
AS
BEGIN
    IF LEN(@Title) < 3
    BEGIN
        PRINT 'Title must be at least 3 characters long.';
        RETURN;
    END
    
    IF @Price <= 0
    BEGIN
        PRINT 'Price must be greater than 0.';
        RETURN;
    END
    
    INSERT INTO Books (title, price, category_id)
    VALUES (@Title, @Price, @CategoryID);
END;
GO

-- Drop and recreate the BookAudit table
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BookAudit')
BEGIN
    DROP TABLE BookAudit;
END;
GO

CREATE TABLE BookAudit (
    BookID INT,
    Operation VARCHAR(50),
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
GO

-- Drop and recreate the LogBookInsert trigger
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'LogBookInsert')
BEGIN
    DROP TRIGGER LogBookInsert;
END;
GO

CREATE TRIGGER LogBookInsert
ON Books
AFTER INSERT
AS
BEGIN
    INSERT INTO BookAudit (BookID, Operation, Timestamp)
    SELECT book_id, 'INSERT', CURRENT_TIMESTAMP
    FROM inserted;
END;
GO

-- Drop and recreate the GetBooksByPrice stored procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetBooksByPrice')
BEGIN
    DROP PROCEDURE GetBooksByPrice;
END;
GO

CREATE PROCEDURE GetBooksByPrice
    @MaxPrice DECIMAL(10, 2)
AS
BEGIN
    IF @MaxPrice <= 0
    BEGIN
        PRINT 'Price must be greater than 0.';
        RETURN;
    END

    SELECT * FROM Books WHERE price < @MaxPrice;
END;
GO

-- Drop and recreate the LogBookDelete trigger
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'LogBookDelete')
BEGIN
    DROP TRIGGER LogBookDelete;
END;
GO

CREATE TRIGGER LogBookDelete
ON Books
AFTER DELETE
AS
BEGIN
    INSERT INTO BookAudit (BookID, Operation, Timestamp)
    SELECT book_id, 'DELETE', CURRENT_TIMESTAMP
    FROM deleted;
END;
GO

-- 7. Role-Based Access Control

GRANT EXECUTE ON GetBooksByCategory TO api_user;
GRANT EXECUTE ON AddBook TO api_user;
GRANT EXECUTE ON GetBooksByPrice TO api_user;
GO