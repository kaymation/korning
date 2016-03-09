-- DEFINE YOUR DATABASE SCHEMA HERE

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS frequencies;

CREATE TABLE products(
  Id SERIAL PRIMARY KEY,
  Name VARCHAR(255)
);

CREATE TABLE employees(
  Id SERIAL PRIMARY KEY,
  Name VARCHAR(255),
  Email VARCHAR(255)
);

CREATE TABLE customers(
  Id SERIAL PRIMARY KEY,
  Name VARCHAR(255),
  Account_no VARCHAR(225)
);

CREATE TABLE frequencies(
  Id SERIAL PRIMARY KEY,
  Name VARCHAR(255)
);

CREATE TABLE sales(
  Invoice_no SERIAL PRIMARY KEY,
  Employee_id INT REFERENCES employees(id),
  Account_id INT REFERENCES customers(id),
  Frequency_id INT REFERENCES frequencies(id),
  Product_id INT REFERENCES products(id),
  Sale_date DATE,
  Sale_amount MONEY,
  Units_sold INT
);
