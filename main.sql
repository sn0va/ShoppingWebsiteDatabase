-- Sean Novak

-- OnlinePurchaseDB
-- Original Creation: Monday, November 2, 2020

-- Creating the OnlinePurchase database
DROP SCHEMA IF EXISTS OnlinePurchaseDB;
CREATE SCHEMA IF NOT EXISTS OnlinePurchaseDB;
USE OnlinePurchaseDB;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer (
	customer_ID	INT(5)			NOT NULL,
    address_ID	INT(5)			NOT NULL,
    fName		VARCHAR(15)		NOT NULL,
	lName		VARCHAR(15) 	NOT NULL,
    dBirth		DATE			NOT NULL,
    CONSTRAINT	customerID_PK
		PRIMARY KEY(customer_ID)
) ENGINE=InnoDB;

-- Index for customer.lName
CREATE INDEX last_name ON Customer(lName);

DROP TABLE IF EXISTS Address;
CREATE TABLE Address (
	address_ID		INT(5)			NOT NULL,
	street			VARCHAR(30)		NOT NULL,
    city			VARCHAR(15)		NOT NULL,
    zipCode			INT(5)			NOT NULL,
    state			VARCHAR(15)		NOT NULL,
    country			VARCHAR(15)		NOT NULL,
    CONSTRAINT addID_PK
		PRIMARY KEY (address_ID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS BankInfo;
CREATE TABLE BankInfo (
	customer_ID		INT(5)		NOT NULL,
    account_num		INT(11)	 	NOT NULL,
    bank_name		VARCHAR(15)	NOT NULL,
    CONSTRAINT accountNum_PK
		PRIMARY KEY (account_num),
	FOREIGN KEY (customer_ID)
		REFERENCES Customer(customer_ID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS BankAddress;
CREATE TABLE BankAddress (
	address_ID		INT(5)		NOT NULL,
    bank_name		VARCHAR(15)	NOT NULL,
    FOREIGN KEY (address_ID)
		REFERENCES CustomerAddress(address_ID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS UserInfo;
CREATE TABLE UserInfo (
	customer_ID		INT(5)		NOT NULL	UNIQUE,
	userID			VARCHAR(15)	NOT NULL	UNIQUE,
    password		VARCHAR(15)	UNIQUE,
	FOREIGN KEY (customer_ID)
		REFERENCES Customer(customer_ID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS Billing;
CREATE TABLE Billing (
	bill_ID			INT(5)			NOT NULL,
    customer_ID		INT(5)			NOT NULL,
    account_num		INT(11)			NOT NULL,
    date			DATE			NOT NULL,
    total_price		DECIMAL(5,2)	NOT NULL,
    discount		DECIMAL(5,2),
    CONSTRAINT billID_PK
		PRIMARY KEY (bill_ID),
	FOREIGN KEY (customer_ID)
		REFERENCES Customer(customer_ID),
	CONSTRAINT accountNum_FK
		FOREIGN KEY (account_num)
			REFERENCES BankInfo(account_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS Items;
CREATE TABLE Items (
	item_ID		INT(5)			NOT NULL,
	item_name	VARCHAR(255)	NOT NULL,
    stock		INT(5)			NOT NULL,
    price		DECIMAL(5,2)	NOT NULL,
    CONSTRAINT itemID_PK
		PRIMARY KEY (item_ID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS ItemsBought;
CREATE TABLE ItemsBought (
	bill_ID			INT(5)		NOT NULL,
    item_ID			INT(5)		NOT NULL,
    quantity		SMALLINT(5)	NOT NULL,
	FOREIGN KEY (bill_ID)
		REFERENCES Billing(bill_ID),
	FOREIGN KEY (item_ID)
		REFERENCES Items(item_ID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS Manager;
CREATE TABLE Manager (
	userID		VARCHAR(15)		NOT NULL UNIQUE,
    password	VARCHAR(15)		UNIQUE,
    CONSTRAINT userID_PK
		PRIMARY KEY(userID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS Supplier;
CREATE TABLE Supplier (
	item_ID			INT(5)		NOT NULL,
    address_ID		INT(5)		NOT NULL,
    supplier_name	VARCHAR(50) NOT NULL,
    CONSTRAINT item_PK
		PRIMARY KEY (item_ID),
    CONSTRAINT itemID_FK
		FOREIGN KEY (item_ID)
			REFERENCES Items(item_ID),
	FOREIGN KEY (address_ID)
		REFERENCES CustomerAddress(address_ID)
);

-- Insert sample items into their respective tables
INSERT INTO Customer (customer_ID, address_ID, fName, lName, dBirth) 
VALUES ('091867', 24572, 'John', 'Rose', '1998-03-15'),
 ('435675', 31689, 'Bob', 'Jones', '1987-02-18'),
 ('234768', 12457, 'William', 'Loving', '1971-05-12'),
 ('879054', 24501, 'Billy', 'Johnson', '2000-01-20'),
 ('325876', 58962, 'Greg', 'West', '1995-06-04');
 
INSERT INTO Address (address_ID, street, city, zipcode, state, country)
VAlUES (24572, '327 LivingWell RD', 'Lynchburg', '24501', 'VA', 'United States'),
 (31689, '408 Village DR', 'Amherst', '24521', 'VA', 'United States'),
 (12457, '300 Hilly LN', 'Salem', '97301', 'VA', 'United States'),
 (24501, '205 Hilldale RD', 'Madison Heights', '24572', 'VA', 'United States'),
 (58962, '200 Willyvill LN', 'Bedford', '24523', 'VA', 'United States');

INSERT INTO BankInfo (customer_ID, account_num, bank_name)
VALUES ('091867', '12345', 'Wells Fargo'),
('435675', '37658', 'BB&T'),
('234768', '54678', 'SunTrust'),
('879054', '98234', 'Bank of America'),
('325876', '43678', 'Carter Bank');

INSERT INTO BankAddress (address_ID, bank_name)
VALUES (24572, 'Wells Fargo'),
(31689, 'BB&T'),
(12457, 'SunTrust'),
(24501, 'Bank of America'),
(58962, 'Carter Bank');

INSERT INTO UserInfo (customer_ID, userID, password)
VALUES ('091867', 'JRose', '9087654'),
('435675', 'Bjones', '7685432'),
('234768', 'Wloving', '5463781'),
('879054', 'Bjohnson', '6345624'),
('325876', 'Gwest', '4678923');

INSERT INTO Billing (bill_ID, customer_ID, account_num, date, total_price, discount)
VALUES ('23456', '091867', '12345', '2020-10-23', '500.00', 'NULL'),
('34590', '435675', '37658', '2020-05-17', '200.00', 'NULL'),
('68976', '234768', '89432', '2020-03-18', '50.00', 'NULL'),
('54321', '879054', '76589', '2020-08-16', '300.00', 'NULL'),
('79856', '325876', '26578', '2020-12-07', '100.00', 'NULL');

INSERT INTO Items (item_ID, item_name, stock, price)
VALUES ('68790345', 'Chair', '4', '500.00'),
('90657823', 'TV', '200.00'),
('50436378', 'Table', '50.00'),
('32690546', 'Gaming system', '300.00'),
('47843245', 'Gaming controller', '100.00');

INSERT INTO ItemsBought (bill_ID, item_ID, quantity)
VALUES ('23456', '68790345', '1'),
('34590', '90657823', '1'),
('68976', '50436378', '2'),
('54321', '32690546', '1'),
('79856', '47843245', '1');

INSERT INTO Supplier (item_ID, address_ID, supplier_name)
VALUES ('68790345', 24572, 'Walmart'),
('90657823', 31689, 'Sears'),
('50436378', 12457, 'The Home Depot'),
('32690546', 24501, 'GameStop'),
('47843245', 58962, 'GameStop');

-- Trigger to set a 10% discount on items over 100
DELIMITER$$
CREATE TRIGGER discount
	BEFORE INSERT ON billing 
	FOR EACH ROW
BEGIN
	IF (NEW.total_price >= 100) THEN
		SET NEW.discount = NEW.total_price * 0.1
END$$
DELIMITER ;

-- Select query to show the bills of a given customer as identified by customer_ID
DELIMITER |
CREATE PROCEDURE selectBillsByID(id int)
BEGIN
	SELECT *
		FROM billing
		WHERE customer_ID = id;
END |
DELIMITER ;

-- Select query to show the bills of a given customer as identified by lName
DELIMITER |
CREATE PROCEDURE selectBillsByLName( inName varchar(15))
BEGIN
	SELECT *
		FROM billing
		WHERE custID = (SELECT customer_ID
			FROM customer
            WHERE lname = inName);
END |
DELIMITER ;

-- View to show the average bills per zip code
CREATE VIEW avgBillsPerZip as
	SELECT avg(b.total_price) as average, ca.zipCode
    FROM billing b, customer c, customeraddress ca
	WHERE b.customer_ID = c.customer_ID
    and c.customer_ID = ca.customer_ID
    GROUP BY ca.zipCode;
SELECT * FROM avgBillsPerZip;

-- View to show the three latest bills for the user
CREATE VIEW currentBills as
	SELECT * FROM billing
    ORDER BY date desc
    LIMIT 3;
SELECT * FROM currentBills;

-- More sample inputs
INSERT INTO Customer VALUES(4444, 'John', 'Smith', '1998-07-15');

INSERT INTO Items VALUES 
(1111, 'Tea', 20, 19.99),
(2222, 'Lemon', 30, 9.99),
(3333, 'Coffee', 15, 15.50);

INSERT INTO Supplier (item_ID, supplier_name) VALUES
(1111, 'Walmart'),
(2222, 'Kroger'),
(3333, 'Starbucks');

INSERT INTO BankInfo VALUES
(4444, 00900, 'Capital One');

-- Sample purchase
INSERT INTO Billing VALUES
(77777, 4444, 00900, '2020-11-14', 29.98, 0);

INSERT INTO ItemsBought VALUES
(77777, 1111, 1),
(77777, 2222, 1);