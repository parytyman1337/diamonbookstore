-- Categories Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Categories' AND xtype='U')
CREATE TABLE Categories (
  category_id INT PRIMARY KEY IDENTITY(1,1),
  name VARCHAR(255) NOT NULL,
  parent_category_id INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id),
  CONSTRAINT chk_category_name CHECK (LEN(name) > 0)
);

-- Books Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Books' AND xtype='U')
CREATE TABLE Books (
  book_id INT PRIMARY KEY IDENTITY(1,1),
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NULL,
  isbn VARCHAR(13) UNIQUE NOT NULL,
  description VARCHAR(MAX) NULL,
  price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
  currency VARCHAR(10) NOT NULL DEFAULT 'USD' CHECK (currency IN ('USD', 'EUR', 'GBP')),
  publication_date DATE NULL,
  publisher VARCHAR(255) NULL,
  stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  category_id INT NULL,
  language VARCHAR(50) NOT NULL DEFAULT 'English',
  format VARCHAR(50) NOT NULL DEFAULT 'Paperback',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES Categories(category_id),
  CONSTRAINT chk_title CHECK (LEN(title) > 0)
);

-- Customers Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Customers' AND xtype='U')
CREATE TABLE Customers (
  customer_id INT PRIMARY KEY IDENTITY(1,1),
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL CHECK (email LIKE '%_@__%.__%'),
  phone VARCHAR(20) NULL,
  address VARCHAR(MAX) NOT NULL CHECK (LEN(address) > 0),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')
CREATE TABLE Orders (
  order_id INT PRIMARY KEY IDENTITY(1,1),
  customer_id INT NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount > 0),
  order_status VARCHAR(50) NOT NULL CHECK (order_status IN ('pending', 'shipped', 'delivered', 'canceled')),
  payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('credit_card', 'paypal', 'bank_transfer')),
  shipping_address VARCHAR(MAX) NOT NULL CHECK (LEN(shipping_address) > 0),
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  shipping_date DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Order Items Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Order_Items' AND xtype='U')
CREATE TABLE Order_Items (
  order_item_id INT PRIMARY KEY IDENTITY(1,1),
  order_id INT NOT NULL,
  book_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
  FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- Book Images Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Book_Images' AND xtype='U')
CREATE TABLE Book_Images (
  image_id INT PRIMARY KEY IDENTITY(1,1),
  book_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  is_primary BIT NOT NULL,
  FOREIGN KEY (book_id) REFERENCES Books(book_id),
  CONSTRAINT chk_image_url CHECK (LEN(image_url) > 0)
);

-- Reviews Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Reviews' AND xtype='U')
CREATE TABLE Reviews (
  review_id INT PRIMARY KEY IDENTITY(1,1),
  book_id INT NOT NULL,
  customer_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text VARCHAR(MAX) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (book_id) REFERENCES Books(book_id),
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Example to update 'updated_at' field on update
UPDATE Books
SET title = 'New Title', updated_at = CURRENT_TIMESTAMP
WHERE book_id = 1;
