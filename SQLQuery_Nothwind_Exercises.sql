
    --1. What is the undiscounted subtotal for each Order (identified by OrderID).
	select orders.orderid, orders.customerid, orders.orderdate, (od.unitprice * od.quantity) as undiscountedSubtotal
	from orders
		join [order details] od
		on orders.orderid = od.orderid

    --2. What products are currently for sale (not discontinued)?

	select *
	from products 
	where discontinued = 0 --ANCA: Discontinued is of the tpe bit - an integer data type that can take a value of 1, 0 or null - true can be converted to 1 and false to 0

    --3. What is the cost after discount for each order?  Discounts should be applied as a percentage off.
	select od.orderid, od.unitprice * od.quantity * od.discount as discountedTotal
	from [order details] od
	where od.discount != 0

	--ANCA NOTE: Still gettign errors below!!
	select orders.orderid, orders.customerid, orders.orderdate, (od.unitprice * od.quantity) as undiscountedSubtotal, od.discount, (select od.unitprice * od.quantity * od.discount as discountedTotal
	from [order details] od
	where od.discount != 0)
	from orders
	join [order details] od
	on orders.orderid = od.orderid

    --4. I need a list of sales figures broken down by category name.  Include the total $ amount sold over all time and the total number of items sold.
    --5. What are our 10 most expensive products?
    --6. In which quarter in 1997 did we have the most revenue?
    --7. Which products have a price that is higher than average?