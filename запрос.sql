USE [stack]
GO

--������� 1

-- ������� �������� ���� �������� - ������������ ������� (������)
-- ���������� 1) ��� ������, � ������� ������� ������� � ������ �������������
-- 2)���������� ������� � ��������� ������������� � ������ ��������� ������
-- ��������� ������ ������� � ����� ���������:
-- order_id (row_id ������)
-- customer (������������ ���������)
-- items_count (���������� ������� � ������ ������������� � ���� ������)

IF OBJECT_ID ('select_orders_by_item_name') IS NOT NULL  
   DROP FUNCTION select_orders_by_item_name;  
GO

CREATE FUNCTION select_orders_by_item_name(@ItemName nvarchar(max))
RETURNS Table AS RETURN   
(  
  SELECT	Orders.row_id AS order_id, Customers.name AS customer, COUNT(Orders.row_id) AS items_count
	FROM	Orders, OrderItems, Customers 
	WHERE	Orders.customer_id = Customers.row_id AND 
			OrderItems.order_id = Orders.row_id AND 
			OrderItems.name = @ItemName
	GROUP BY Orders.row_id, Customers.name, OrderItems.name
);
GO
-- ������� ������� 1
-- select * from select_orders_by_item_name(N'����')
-- select * from select_orders_by_item_name(N'�������� �������')
-- select * from stack.dbo.select_orders_by_item_name(N'������')



--������� 2
-- ������� is_root ���������, �������� �� ������� ������� orders �������, ��� �� �������
-- ���������� bit 0(���, �����) ��� 1(��, ������)
IF OBJECT_ID ('is_root') IS NOT NULL  
   DROP FUNCTION is_root;  
GO

CREATE FUNCTION is_root(@RowId int)
RETURNS BIT AS BEGIN   
	IF (SELECT TOP 1 group_name 
		FROM Orders 
		WHERE row_id = @RowId) IS NOT NULL
	        RETURN 1
		RETURN 0
END;
GO

-- ������� calculate_total_price_for_orders_group �������� row_id ������ (���� ������),
-- ���������� ����� - ��������� ��������� ���� ������� ���� ������� � ���� ������ (������)
-- ������������ ����������� �� ����� ��������� �������, ������������� � ������ ������.
-- �������� ������� is_root ��� �������� �� ������
IF OBJECT_ID ('calculate_total_price_for_orders_group') IS NOT NULL  
   DROP FUNCTION calculate_total_price_for_orders_group;  
GO

CREATE FUNCTION calculate_total_price_for_orders_group(@RowId int)
RETURNS INT AS BEGIN   
    DECLARE @total_sum INT;
	SET @total_sum = 0;
    IF dbo.is_root(@RowId) = 1
		SELECT	@total_sum = @total_sum + dbo.calculate_total_price_for_orders_group(o.row_id)
		FROM	Orders AS o
		WHERE	o.parent_id = @RowId
	ELSE
        SELECT	@total_sum = sum(i.price)
        FROM	Orders AS o JOIN OrderItems AS i ON o.row_id = i.order_id
        WHERE	o.row_id = @RowId
    RETURN	@total_sum
END;
GO


-- ������� ������� 2
--select dbo.calculate_total_price_for_orders_group(1) as total_price1   -- 703, ��� ������
--select dbo.calculate_total_price_for_orders_group(2) as total_price2   -- 513, ������ '������� ����'
--select dbo.calculate_total_price_for_orders_group(3) as total_price3   -- 510, ������ '����������'
--select dbo.calculate_total_price_for_orders_group(12) as total_price12  -- 190, ������ '����������� ����'
--select dbo.calculate_total_price_for_orders_group(13) as total_price13  -- 190, ����� '�� �������'


--������� 3
-- ������ ���������� ������������ ���� �����������, � ������� 
-- ������ ����� � 2020 ���� �������� ��� ������� ���� �������� � ������������� "�������� �������".

SELECT Customers.name
FROM 
	Orders, OrderItems, Customers 
WHERE 
		Orders.customer_id = Customers.row_id 
	AND OrderItems.order_id = Orders.row_id
	AND Orders.registered_at > '2019-12-31'  
	AND Orders.registered_at < '2021-01-01' 
GROUP BY Customers.name
HAVING	COUNT(DISTINCT OrderItems.order_id)
		=
		COUNT(DISTINCT 
			CASE WHEN OrderItems.name = N'�������� �������' 
			THEN OrderItems.order_id END) 
		;