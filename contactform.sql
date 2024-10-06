CREATE TABLE ContactForm (
    contact_id INT IDENTITY(1,1) PRIMARY KEY,            -- Unique ID for each contact form submission
    full_name NVARCHAR(100) NOT NULL,                    -- Full name of the customer
    email NVARCHAR(255) NOT NULL CHECK (email LIKE '%@%.%'),  -- Email validation: must contain "@" and "."
    phone_number NVARCHAR(15) CHECK (LEN(phone_number) BETWEEN 7 AND 15), -- Phone number length validation
    message NVARCHAR(MAX) NOT NULL,                      -- Message or inquiry from the customer
    status NVARCHAR(20) DEFAULT 'Pending',               -- Status of the inquiry
    ip_address NVARCHAR(45),                             -- Capture the IP address of the customer
    deleted BIT DEFAULT 0,                               -- Soft delete flag, default is 0 (false)
    submission_date DATETIME DEFAULT GETDATE(),          -- Date and time of submission
    last_updated DATETIME DEFAULT GETDATE()              -- Track when the entry was last updated
);

-- Add some indexes to improve search performance
CREATE INDEX idx_email ON ContactForm (email);
CREATE INDEX idx_submission_date ON ContactForm (submission_date);
CREATE INDEX idx_status ON ContactForm (status);

-- Sample insert for testing the form
INSERT INTO ContactForm (full_name, email, phone_number, message, ip_address)
VALUES ('Jane Doe', 'janedoe@example.com', '987-654-3210', 'I need help with my order.', '192.168.1.100');