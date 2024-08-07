
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Balance DECIMAL(10,2),
    LastModified DATE
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    AccountID INT,
    Amount DECIMAL(10,2),
    TransactionType ENUM('Deposit', 'Withdrawal'),
    TransactionDate DATE
);

CREATE TABLE AuditLog (
    AuditID INT PRIMARY KEY AUTO_INCREMENT,
    TransactionID INT,
    AccountID INT,
    Amount DECIMAL(10,2),
    TransactionType ENUM('Deposit', 'Withdrawal'),
    TransactionDate DATE,
    LogDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
VALUES
(1, 'Alice Johnson', '1980-12-15', 1500.00, CURDATE()),
(2, 'Bob Smith', '1975-05-20', 2000.00, CURDATE());


INSERT INTO Transactions (AccountID, Amount, TransactionType, TransactionDate)
VALUES
(1, 500.00, 'Deposit', CURDATE()),
(1, 200.00, 'Withdrawal', CURDATE()),
(2, 1000.00, 'Deposit', CURDATE());

-- Trigger for Scenario 1: Update LastModified Date on Customer Update
DELIMITER $$

CREATE TRIGGER UpdateCustomerLastModified
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    SET NEW.LastModified = CURDATE();
END $$

DELIMITER ;


UPDATE Customers
SET Balance = Balance + 100
WHERE CustomerID = 1;

SELECT * FROM Customers;


DELIMITER $$

CREATE TRIGGER LogTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TransactionID, AccountID, Amount, TransactionType, TransactionDate)
    VALUES (NEW.TransactionID, NEW.AccountID, NEW.Amount, NEW.TransactionType, NEW.TransactionDate);
END $$

DELIMITER ;


INSERT INTO Transactions (AccountID, Amount, TransactionType, TransactionDate)
VALUES (1, 500.00, 'Deposit', CURDATE());

SELECT * FROM AuditLog;


DELIMITER $$

CREATE TRIGGER CheckTransactionRules
BEFORE INSERT ON Transactions
FOR EACH ROW
BEGIN
    DECLARE v_balance DECIMAL(10,2);

    SELECT Balance INTO v_balance
    FROM Customers
    WHERE CustomerID = NEW.AccountID;

    IF NEW.TransactionType = 'Withdrawal' AND v_balance < NEW.Amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Insufficient funds for withdrawal';
    END IF;

    IF NEW.TransactionType = 'Deposit' AND NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Deposit amount must be positive';
    END IF;
END $$

DELIMITER ;


INSERT INTO Transactions (AccountID, Amount, TransactionType, TransactionDate)
VALUES (1, 200.00, 'Deposit', CURDATE());


INSERT INTO Transactions (AccountID, Amount, TransactionType, TransactionDate)
VALUES (1, -50.00, 'Deposit', CURDATE());


INSERT INTO Transactions (AccountID, Amount, TransactionType, TransactionDate)
VALUES (2, 600.00, 'Withdrawal', CURDATE());

SELECT * FROM Transactions;
