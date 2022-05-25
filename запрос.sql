USE [stack]
GO

--Задание 1

-- функция получает один аргумент - наименование позиции (строка)
-- возвращает 1) все заказы, в которых имеется позиция с данным наименованием
-- 2)количество позиций с указанным наименованием в каждом отдельном заказе
-- Результат вызова таблица с тремя колонками:
-- order_id (row_id заказа)
-- customer (наименование заказчика)
-- items_count (количество позиций с данным наименованием в этом заказе)

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
-- примеры задания 1
-- select * from select_orders_by_item_name(N'Факс')
-- select * from select_orders_by_item_name(N'Кассовый аппарат')
-- select * from stack.dbo.select_orders_by_item_name(N'Стулья')



--Задание 2
-- функция is_root проверяет, является ли элемент таблицы orders группой, или же заказом
-- возвращает bit 0(нет, заказ) или 1(да, группа)
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

-- функция calculate_total_price_for_orders_group получает row_id группы (либо заказа),
-- возвращает число - суммарную стоимость всех позиций всех заказов в этой группе (заказе)
-- суммирование выполняется по всему поддереву заказов, начинающемуся с данной группы.
-- вызывает функцию is_root для проверки на группу
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


-- примеры задания 2
--select dbo.calculate_total_price_for_orders_group(1) as total_price1   -- 703, все заказы
--select dbo.calculate_total_price_for_orders_group(2) as total_price2   -- 513, группа 'Частные лица'
--select dbo.calculate_total_price_for_orders_group(3) as total_price3   -- 510, группа 'Оргтехника'
--select dbo.calculate_total_price_for_orders_group(12) as total_price12  -- 190, группа 'Юридические лица'
--select dbo.calculate_total_price_for_orders_group(13) as total_price13  -- 190, заказ 'ИП Федоров'


--Задание 3
-- запрос возвращает наименования всех покупателей, у которых 
-- каждый заказ в 2020 году содержит как минимум одну позициию с наименованием "Кассовый аппарат".

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
			CASE WHEN OrderItems.name = N'Кассовый аппарат' 
			THEN OrderItems.order_id END) 
		;