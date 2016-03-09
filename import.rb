# Use this file to import the sales information into the
# the database.

require "pg"
require 'csv'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

system("psql korning < schema.sql")

sales = CSV.readlines("sales.csv",headers: true)

employees = sales.map   { |datum| datum["employee"]  }.uniq
customers = sales.map   { |datum| datum["customer_and_account_no"] }.uniq
products = sales.map    { |datum| datum["product_name"] }.uniq
frequencies = sales.map { |datum| datum["invoice_frequency"]}.uniq

db_connection do |connection|

  employees.each do |employee|
    temp = employee.split(" (")
    name = temp[0]
    email = temp[1][0..-2]
    connection.exec_params("INSERT INTO employees(name, email) VALUES($1, $2)", [name, email])
  end

  customers.each do |customer|
    temp = customer.split(" (")
    name = temp[0]
    account_no = temp[1][0..-1]
    connection.exec_params("INSERT INTO customers(name, account_no) VALUES($1, $2)", [name, account_no])
  end

  products.each do |product|
    connection.exec_params("INSERT INTO products(name) VALUES($1)", [product])
  end

  frequencies.each do |frequency|
    connection.exec_params("INSERT INTO frequencies(name) VALUES($1)", [frequency])
  end

  sales.each do |sale|
    emp_name = sale["employee"].split(" (").first
    cust_name = sale["customer_and_account_no"].split(" (").first
    employee_id = connection.exec("SELECT id FROM employees WHERE employees.name = '#{emp_name}'").first["id"]
    customer_id = connection.exec("SELECT id FROM customers WHERE customers.name = '#{cust_name}'").first["id"]
    frequency_id = connection.exec("SELECT id FROM frequencies WHERE frequencies.name = '#{sale["invoice_frequency"]}'").first["id"]
    product_id = connection.exec("SELECT id FROM products WHERE products.name = '#{sale["product_name"]}'").first["id"]
    # binding.pry
    connection.exec_params(
      "INSERT INTO sales(employee_id,account_id,frequency_id, product_id, sale_date, sale_amount, units_sold) VALUES ($1, $2, $3, $4, $5, $6, $7)",
      [
        employee_id,
        customer_id,
        frequency_id,
        product_id,
        sale["sale_date"],
        sale["sale_amount"],
        sale["units_sold"]
      ]
    )
  end
end
