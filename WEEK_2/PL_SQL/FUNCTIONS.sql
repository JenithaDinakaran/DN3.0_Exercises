
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    DOB DATE,
    Balance DECIMAL(10,2),
    LastModified DATE
);


CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT,
    LoanAmount DECIMAL(10,2),
    InterestRate DECIMAL(5,2),
    DurationYears INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
VALUES
(1, 'Alice Johnson', '1980-12-15', 1500.00, CURDATE()),
(2, 'Bob Smith', '1975-06-20', 2500.00, CURDATE()),
(3, 'Charlie Brown', '1990-05-10', 3500.00, CURDATE());


INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, DurationYears)
VALUES
(1, 1, 5000.00, 5.00, 5),
(2, 2, 10000.00, 4.00, 10),
(3, 3, 15000.00, 3.50, 15);


DELIMITER $$

CREATE FUNCTION CalculateAge(dob DATE) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE age INT;
    SET age = TIMESTAMPDIFF(YEAR, dob, CURDATE());
    RETURN age;
END $$

DELIMITER ;


SELECT Name, DOB, CalculateAge(DOB) AS Age
FROM Customers;


DELIMITER $$

CREATE FUNCTION CalculateMonthlyInstallment(
    loan_amount DECIMAL(10,2),
    interest_rate DECIMAL(5,2),
    duration_years INT
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE monthly_interest_rate DECIMAL(5,4);
    DECLARE months INT;
    DECLARE monthly_installment DECIMAL(10,2);
    
    SET monthly_interest_rate = interest_rate / 1200;  -- Convert annual interest rate to monthly and percentage to decimal
    SET months = duration_years * 12;
    SET monthly_installment = loan_amount * monthly_interest_rate / (1 - POW(1 + monthly_interest_rate, -months));
    
    RETURN monthly_installment;
END $$

DELIMITER ;


SELECT LoanID, LoanAmount, InterestRate, DurationYears, 
       CalculateMonthlyInstallment(LoanAmount, InterestRate, DurationYears) AS MonthlyInstallment
FROM Loans;


DELIMITER $$

CREATE FUNCTION HasSufficientBalance(account_id INT, amount DECIMAL(10,2)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE balance DECIMAL(10,2);
    
    SELECT Balance INTO balance
    FROM Customers
    WHERE CustomerID = account_id;
    
    RETURN balance >= amount;
END $$

DELIMITER ;


SELECT CustomerID, Balance, HasSufficientBalance(CustomerID, 2000.00) AS HasSufficientBalance
FROM Customers;
