
    --1. What is the undiscounted subtotal for each Order (identified by OrderID).
	--Anca notes: get orders table and join  the order details table on the order id to get all the details of an order >
	-- > then group by order data I want to show - like order id, date, and customer id >
	--> and then multiply the unitprice and quantity for each piece in the order details >
	-- > and last, sum them up together to display in a new column aliased as undiscountedSubtotal:
	select orders.orderid, orders.customerid, orders.orderdate, sum(od.unitprice * od.quantity) as undiscountedSubtotal
	from orders
		join [order details] od
		on orders.orderid = od.orderid
	group by orders.orderid, orders.CustomerID, orders.OrderDate

    --2. What products are currently for sale (not discontinued)?
	--ANCA: Discontinued is of the type bit - an integer data type that can take a value of 1, 0 or null - true can be converted to 1 and false to 0
	--we need the products where discontinued is false so where it is 0
	select *
	from products 
	where discontinued = 0 

	--ANCA: here are the products that have been discontinued:
	select *
	from products 
	where discontinued = 1

    --3. What is the cost after discount for each order?  Discounts should be applied as a percentage off.
	--ANCA QUESTION: Can we just multiply the discount value??
	--get order details:
	select *
	from [order details] od

	--group order details by order id and calculate order total:
	select sum(od.unitprice * od.quantity) as orderTotal
	from [order details] od
	group by OrderID

	--Anca: testing the operation to get the discounted cost:
	select od.orderid, sum(od.unitprice * od.quantity * od.discount) as discountedTotal
	from [order details] od
	where od.discount != 0
	group by od.OrderID

	--Anca: testing to check where the discount is 0:
	select orders.orderid, orders.customerid, orders.orderdate, (od.unitprice * od.quantity) as undiscountedSubtotal, od.discount
	from orders
	join [order details] od
	on orders.orderid = od.orderid

		--ANCA: displaying all individual order details and calculating the total with a CASE statement for when discount is 0 or not:
	select od.orderId, od.productId, od.discount,
		case when od.Discount != 0 then (od.unitprice * od.quantity * od.Discount)
		else (od.unitprice * od.quantity)	
		end as unitTotal
	from [order details] od

	--ANCA: THEN wrap the main query around the one above- which gives me the subset I need! FINAL ANSWER for #3!
	select orderid, sum(unitTotal) as orderTotalAfterDiscounts
	from (
	select od.orderId, od.productId, od.discount,
		case when od.Discount != 0 then (od.unitprice * od.quantity * od.Discount)
		else (od.unitprice * od.quantity)	
		end as unitTotal
	from [order details] od) orderDiscountCalcsSet -- ANCA: all subqueries wrapped like this need an alias!
	group by orderid


    --4. I need a list of sales figures broken down by category name.  Include the total $ amount sold over all time and the total number of items sold.
	--ANCA: QUESTION: should we subtract the discount from the total to get a true total $ amount sold?
	select *
	from Categories

	select *
	from Orders

	select *
	from Products

	select *
	from [Order Details]

	--ANCA: initial calculation - NOT taking discount into consideration:
	select c.CategoryName, c.CategoryID, sum(od.quantity) as numberOfUnitsSold, sum(od.unitprice * od.Quantity) as totalAmountSoldBeforeDiscounts
	from [Order Details] od
		join Products p
		on od.ProductID = p.ProductID
			join Categories c
			on p.categoryId = c.categoryId
	group by c.CategoryID, c.CategoryName


	--Acna: list of all units with category info:
	select od.orderId, od.productId, od.discount, p.CategoryID, c.categoryName, od.Quantity as unitCount,
		case when od.Discount != 0 then (od.unitprice * od.quantity * od.Discount)
		else (od.unitprice * od.quantity)	
		end as unitTotal
	from [order details] od 
		join Products p
		on od.ProductID = p.ProductID
			join Categories c
			on p.CategoryID = c.CategoryID

	--FINAL ANSWER FOR #4
	select CategoryID, CategoryName, sum(unitTotal) as totalAmountSoldByCategoryAfterDiscounts, sum(unitCount) as totalUnitsSold
	from (
			select od.orderId, od.productId, od.discount, p.CategoryID, c.categoryName, od.Quantity as unitCount,
		case when od.Discount != 0 then (od.unitprice * od.quantity * od.Discount)
		else (od.unitprice * od.quantity)	
		end as unitTotal
	from [order details] od 
		join Products p
		on od.ProductID = p.ProductID
			join Categories c
			on p.CategoryID = c.CategoryID) unitTotalsAfterDiscounts
	group by CategoryID,CategoryName
	

    --5. What are our 10 most expensive products? ANCA: question by unit price right?
	select top 10 *
	from Products 
	order by UnitPrice desc


    --6. In which quarter in 1997 did we have the most revenue?
	select top 1 DATEPART(YEAR, orderdate) [YEAR], DATEPART(QUARTER, orderdate) [Quarter], sum(unitTotal) as orderTotalsByDate
	from (
	select od.orderId, od.productId, od.discount, o.orderdate,
		case when od.Discount != 0 then (od.unitprice * od.quantity * od.Discount)
		else (od.unitprice * od.quantity)	
		end as unitTotal
	from [order details] od
		join Orders o
		on o.OrderID = od.OrderID
	) orderDiscountCalcsSet -- ANCA: all subqueries wrapped like this need an alias!
	where DATEPART(YEAR, orderdate) = '1997'
	group by DATEPART(YEAR, orderdate), DATEPART(QUARTER, orderdate)
	order by orderTotalsByDate desc


    --7. Which products have a price that is higher than average?

	select ProductID, ProductName, UnitPrice
	from Products
	where UnitPrice > (select AVG(unitprice) as averagePrice from Products)

	--to test:
	select AVG(unitprice) as averageUnitPrice
	from Products

	select ProductID, ProductName, UnitPrice
	from Products
	where UnitPrice > 28.86