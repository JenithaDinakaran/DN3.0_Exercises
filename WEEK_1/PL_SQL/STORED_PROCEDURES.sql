CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Balance DECIMAL(10, 2),
    LastModified DATE
);


CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(20),
    Balance DECIMAL(10, 2),
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Salary DECIMAL(10, 2),
    Department VARCHAR(50),
    HireDate DATE
);


INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified) VALUES
(1, 'Alice Johnson', '1980-12-15', 1500.00, NOW()),
(2, 'Bob Smith', '1990-07-22', 2000.00, NOW());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified) VALUES
(101, 1, 'Savings', 1000.00, NOW()),
(102, 1, 'Checking', 500.00, NOW()),
(201, 2, 'Savings', 1500.00, NOW());


INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate) VALUES
(1, 'John Doe', 'Manager', 50000.00, 'Sales', '2020-01-15'),
(2, 'Jane Smith', 'Developer', 60000.00, 'IT', '2019-03-22');

DELIMITER $$

CREATE PROCEDURE ProcessMonthlyInterest()
BEGIN
    -- Update the balance for all savings accounts by adding 1% interest
    UPDATE Accounts
    SET Balance = Balance * 1.01
    WHERE AccountType = 'Savings';
END $$

DELIMITER ;

-- Output for Scenario 1
CALL ProcessMonthlyInterest();
SELECT * FROM Accounts;
