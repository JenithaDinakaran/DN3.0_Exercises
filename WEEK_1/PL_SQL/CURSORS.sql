
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT,
    Amount DECIMAL(10,2),
    TransactionType ENUM('Deposit', 'Withdrawal'),
    TransactionDate DATE
);

CREATE TABLE Accounts (
    AccountID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Balance DECIMAL(10,2)
);

CREATE TABLE Loans (
    LoanID INT AUTO_INCREMENT PRIMARY KEY,
    AccountID INT,
    LoanAmount DECIMAL(10,2),
    InterestRate DECIMAL(5,2)
);


INSERT INTO Accounts (CustomerID, Balance) VALUES
(1, 1000.00),
(2, 1500.00),
(3, 500.00);


INSERT INTO Transactions (AccountID, Amount, TransactionType, TransactionDate) VALUES
(1, 200.00, 'Deposit', '2024-08-01'),
(1, -50.00, 'Withdrawal', '2024-08-15'),
(2, 100.00, 'Deposit', '2024-08-10');


INSERT INTO Loans (AccountID, LoanAmount, InterestRate) VALUES
(1, 5000.00, 5.00),
(2, 10000.00, 4.50);


DELIMITER $$

CREATE PROCEDURE GenerateMonthlyStatements()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_account_id INT;
    DECLARE v_amount DECIMAL(10,2);
    DECLARE v_transaction_type ENUM('Deposit', 'Withdrawal');
    DECLARE v_transaction_date DATE;

    DECLARE cur CURSOR FOR
        SELECT AccountID, Amount, TransactionType, TransactionDate
        FROM Transactions
        WHERE MONTH(TransactionDate) = MONTH(CURDATE())
        AND YEAR(TransactionDate) = YEAR(CURDATE());
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_account_id, v_amount, v_transaction_type, v_transaction_date;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT CONCAT('Account ID: ', v_account_id, 
                      ', Amount: ', v_amount, 
                      ', Type: ', v_transaction_type, 
                      ', Date: ', v_transaction_date) AS Statement;
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

CALL GenerateMonthlyStatements();

SELECT * FROM Accounts;


DELIMITER $$

CREATE PROCEDURE ApplyAnnualFee()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_account_id INT;
    DECLARE v_balance DECIMAL(10,2);
    DECLARE annual_fee DECIMAL(10,2) DEFAULT 50.00; -- Example annual fee

    DECLARE cur CURSOR FOR
        SELECT AccountID, Balance
        FROM Accounts;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_account_id, v_balance;
        IF done THEN
            LEAVE read_loop;
        END IF;

        UPDATE Accounts
        SET Balance = v_balance - annual_fee
        WHERE AccountID = v_account_id;
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;


CALL ApplyAnnualFee();

SELECT * FROM Accounts;


DELIMITER $$

CREATE PROCEDURE UpdateLoanInterestRates()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_loan_id INT;
    DECLARE v_interest_rate DECIMAL(5,2);
    DECLARE new_interest_rate DECIMAL(5,2);

    DECLARE cur CURSOR FOR
        SELECT LoanID, InterestRate
        FROM Loans;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_loan_id, v_interest_rate;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET new_interest_rate = v_interest_rate + 0.50; -- Example increase of 0.50%
        
        UPDATE Loans
        SET InterestRate = new_interest_rate
        WHERE LoanID = v_loan_id;
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;


CALL UpdateLoanInterestRates();

SELECT * FROM Loans;
