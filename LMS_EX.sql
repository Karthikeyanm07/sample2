
use lms1;

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    membership_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    membership_status ENUM('Active', 'Inactive') DEFAULT 'Active'
);


CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    author VARCHAR(255),
    publisher VARCHAR(255),
    genre VARCHAR(100),
    quantity INT DEFAULT 0,
    available_quantity INT DEFAULT 0
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    transaction_type ENUM('Borrow', 'Return'),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME,
    return_date DATETIME,
    fine DECIMAL(5, 2) DEFAULT 0.00,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);


CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT,
    fine_amount DECIMAL(5, 2),
    paid_status ENUM('Paid', 'Unpaid') DEFAULT 'Unpaid',
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);


CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(255)
);


CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

select * from authors;
select * from book_authors;
select * from books;
select * from fines;
select * from members;
select * from transactions;
select * from reservations;

-- 1) Insert a New Member

INSERT INTO members (first_name, last_name, email, phone)
VALUES ('John', 'Doe', 'john.doe@example.com', '1234567890');

-- 2) Insert a New Book

INSERT INTO books (title, author, publisher, genre, quantity, available_quantity)
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald', 'Charles Scribner\'s Sons', 'Fiction', 5, 5);

-- 3) Borrow a Book
-- When a member borrows a book, the system updates the transaction and reduces the available quantity.

INSERT INTO transactions (member_id, book_id, transaction_type, due_date)
VALUES (1, 1, 'Borrow', '2025-03-10');
UPDATE books SET available_quantity = available_quantity - 1 WHERE book_id = 1;

-- 4)Return a Book
-- --( When a member returns a book, the system updates the transaction, calculates fines if applicable, 
--  and updates the available quantity.)

UPDATE transactions SET return_date = NOW() WHERE transaction_id = 1;
UPDATE books SET available_quantity = available_quantity + 1 WHERE book_id = 1;

-- If the book is returned late, calculate the fine

UPDATE transactions
SET fine = DATEDIFF(CURDATE(), due_date) * 1.00  -- Assuming 1.00 is the fine per day
WHERE transaction_id = 1 AND DATEDIFF(CURDATE(), due_date) > 0;

-- 5) Insert a Fine

INSERT INTO fines (transaction_id, fine_amount)
VALUES (1, 5.00);  -- Fine for late return

-- 6) View All Borrowed Books

SELECT m.first_name, m.last_name, b.title, t.transaction_date, t.due_date, t.return_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow' AND t.return_date IS NULL;

-- 7) View All Overdue Books

SELECT m.first_name, m.last_name, b.title, t.due_date, DATEDIFF(CURDATE(), t.due_date) AS overdue_days
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.transaction_type = 'Borrow' AND t.return_date IS NULL AND DATEDIFF(CURDATE(), t.due_date) > 0;

-- 8) View Member’s Borrowing History

SELECT m.first_name, m.last_name, b.title, t.transaction_type, t.transaction_date, t.due_date, t.return_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE m.member_id = 1;

-- 9).-- View All Books in the Library

SELECT book_id, title, author, genre, quantity, available_quantity
FROM books;

-- 10) View All Members in the Library

SELECT member_id, first_name, last_name, email, membership_status
FROM members;

-- SPECIAL FUNCNTIONALITIES --
-- 1)Search Books by Title, Author, or Genre

SELECT * FROM books WHERE title LIKE '%ponni%' OR author LIKE '%scott%' OR genre LIKE '%Fiction%';
SELECT * FROM books WHERE title LIKE '%graet%' OR author LIKE '%scott%' ;

-- 2) Overdue Fine Management
	-- Automatically Update Fine:
UPDATE transactions
SET fine = DATEDIFF(CURDATE(), due_date) * 1.00
WHERE return_date IS NULL AND DATEDIFF(CURDATE(), due_date) > 0;

-- Send Reminder for Overdue Books:

SELECT m.email, m.first_name, b.title, t.due_date
FROM transactions t
JOIN members m ON t.member_id = m.member_id
JOIN books b ON t.book_id = b.book_id
WHERE t.return_date IS NULL AND DATEDIFF(CURDATE(), t.due_date) > 0;

-- 3) Book Reservation:
-- Allow members to reserve books that are currently unavailable.

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

INSERT INTO reservations (member_id, book_id, reservation_date, status) VALUES
(1, 1, '2025-03-01 10:30:00', 'Pending'), 
(2, 1, '2025-03-01 11:15:00', 'Pending'), 
(2, 2, '2025-03-02 09:00:00', 'Completed');

-- 4) Reporting System:
-- Generate reports for overdue books, total fines, and member borrowing history.

-- Overdue Books Report:
SELECT * FROM transactions WHERE return_date IS NULL AND due_date < CURDATE();

-- Total Fine Report:--

SELECT SUM(fine_amount) AS total_fines FROM fines WHERE paid_status = 'Unpaid';

-- Member Borrowing History:
SELECT * FROM transactions WHERE member_id = 1;

