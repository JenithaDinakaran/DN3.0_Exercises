
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Balance DECIMAL(10,2)
);

CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    Salary DECIMAL(10,2)
);

CREATE TABLE Accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Balance DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


INSERT INTO Customers (Name, DOB, Balance) VALUES
('Alice Johnson', '1980-12-15', 1500.00),
('Bob Smith', '1990-05-22', 2000.00);


INSERT INTO Employees (Name, Position, Salary) VALUES
('John Doe', 'Manager', 60000.00),
('Jane Smith', 'Developer', 50000.00);


INSERT INTO Accounts (CustomerID, Balance) VALUES
(1, 1000.00),
(2, 1500.00);


DELIMITER $$

CREATE FUNCTION GetCustomerBalance(p_customer_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_balance DECIMAL(10,2);
    SELECT Balance INTO v_balance
    FROM Customers
    WHERE CustomerID = p_customer_id;
    RETURN v_balance;
END $$

DELIMITER ;


SELECT GetCustomerBalance(1);


DELIMITER $$

CREATE FUNCTION CalculateAnnualSalary(p_employee_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    SELECT Salary INTO v_salary
    FROM Employees
    WHERE EmployeeID = p_employee_id;
    RETURN v_salary * 12; 
END $$

DELIMITER ;


SELECT CalculateAnnualSalary(1);


DELIMITER $$

CREATE FUNCTION GetTotalBalance(p_customer_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_balance DECIMAL(10,2);
    SELECT COALESCE(SUM(Balance), 0) INTO v_total_balance
    FROM Accounts
    WHERE CustomerID = p_customer_id;
    RETURN v_total_balance;
END $$

DELIMITER ;


SELECT GetTotalBalance(1);
