CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Balance INT,
    LastModified DATE
);

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT,
    AccountType VARCHAR(20),
    Balance INT,
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT,
    TransactionDate DATE,
    Amount INT,
    TransactionType VARCHAR(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT,
    LoanAmount INT,
    InterestRate INT,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Salary INT,
    Department VARCHAR(50),
    HireDate DATE
); 

-- Corrected INSERT statements

INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
VALUES (1, 'John Doe', STR_TO_DATE('1985-05-15', '%Y-%m-%d'), 1000, NOW());

INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
VALUES (2, 'Jane Smith', STR_TO_DATE('1990-07-20', '%Y-%m-%d'), 1500, NOW());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
VALUES (1, 1, 'Savings', 1000, NOW());

INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
VALUES (2, 2, 'Checking', 1500, NOW());

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (1, 1, NOW(), 200, 'Deposit');

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (2, 2, NOW(), 300, 'Withdrawal');

INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
VALUES (1, 1, 5000, 5, NOW(), DATE_ADD(NOW(), INTERVAL 6 MONTH));

INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', STR_TO_DATE('2015-06-15', '%Y-%m-%d'));

INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', STR_TO_DATE('2017-03-20', '%Y-%m-%d'));

DELIMITER //

CREATE PROCEDURE SafeTransferFunds (
    IN p_from_account_id INT,
    IN p_to_account_id INT,
    IN p_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE v_from_balance DECIMAL(10, 2);

    START TRANSACTION;

    -- Check balance of the source account
    SELECT Balance INTO v_from_balance
    FROM Accounts
    WHERE AccountID = p_from_account_id
    FOR UPDATE;

    IF v_from_balance < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds in the source account.';
    ELSE
        -- Deduct from source account
        UPDATE Accounts
        SET Balance = Balance - p_amount
        WHERE AccountID = p_from_account_id;

        -- Add to destination account
        UPDATE Accounts
        SET Balance = Balance + p_amount
        WHERE AccountID = p_to_account_id;

        COMMIT;
    END IF;
END //

DELIMITER ;
CALL SafeTransferFunds(1, 2, 500.00);
SELECT * FROM Accounts;

DELIMITER $$

CREATE PROCEDURE UpdateSalary (
    IN p_employee_id INT,
    IN p_percentage DECIMAL(5,2)
)
BEGIN
    DECLARE v_current_salary DECIMAL(10,2);

    -- Check if employee exists and get their salary
    SELECT Salary INTO v_current_salary
    FROM Employees
    WHERE EmployeeID = p_employee_id;

    IF v_current_salary IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Employee ID does not exist.';
    ELSE
        -- Update salary
        UPDATE Employees
        SET Salary = Salary + (Salary * p_percentage / 100)
        WHERE EmployeeID = p_employee_id;

        COMMIT;
    END IF;
END $$

DELIMITER ;
CALL UpdateSalary(1, 10.00);
SELECT * FROM Employees;
DELIMITER $$

CREATE PROCEDURE AddNewCustomer (
    IN p_customer_id INT,
    IN p_name VARCHAR(100),
    IN p_dob DATE,
    IN p_balance DECIMAL(10,2)
)
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Handle any SQL exceptions
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error occurred while inserting the customer.';
    END;

    START TRANSACTION;

    -- Insert new customer
    INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
    VALUES (p_customer_id, p_name, p_dob, p_balance, CURDATE());

    COMMIT;
END $$

DELIMITER ;
CALL AddNewCustomer(4, 'Amelia Johnson', '1980-12-15', 1500.00);
SELECT * FROM Customers;