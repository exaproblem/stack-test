use [stack]
go
if object_id('OrderItems') is not null
   drop table OrderItems;
go

if object_id('Orders') is not null
   drop table Orders;
go

if object_id('Customers') is not null
   drop table Customers;
go

--�������
---- ���������
create table Customers
(
   row_id	int		identity	not null,	-- PK
   name		nvarchar(max)		not null,	-- ������������ ���������

   constraint PK_Customers		
		primary key nonclustered(row_id)
);
go

---- ������
create table Orders
(
   row_id			int			identity	not null, -- PK
   parent_id		int,					-- row_id ������������ ������	FK � Orders.row_id
   group_name		nvarchar(max),			-- ������������ ������ �������
   customer_id		int,					-- row_id ���������				FK � Customers.row_id
   registered_at	date					-- ���� ����������� ������

   constraint PK_Orders		
		primary key nonclustered (row_id),
   constraint FK_Orders_Folder 
		foreign key (parent_id) 
			references Orders(row_id)
				on delete no action
				on update no action,
   constraint FK_Customers
		foreign key (customer_id)
			references Customers(row_id)
				on delete cascade
				on update cascade
);
go

---- ������� �������
create table OrderItems
(
   row_id		int			identity	not null,	-- PK
   order_id		int						not null,	-- row_id ������		FK � Orders.row_id
   name			nvarchar(max)			not null,	-- ������������ �������
   price		int						not null,	-- ��������� ������� � ������

	constraint PK_OrderItems
		primary key nonclustered (row_id),
	constraint FK_OrderItems_Orders
		foreign key (order_id) 
			references Orders(row_id)
				on delete cascade
				on update cascade
);
go

--������
insert into Customers                                                   -- 1
	values(N'������');
insert into Customers                                                   -- 2
	values(N'������');
insert into Customers                                                   -- 3
	values(N'�������');
insert into Customers                                                   -- 4
	values(N'�� �������');


insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 1
	values (null, N'��� ������', null, null);
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 2
	values (1, N'������� ����', null, null);
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 3
	values (2, N'����������', null, null);
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 4
	values (3, null, 1, '2019/10/02');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 5
	values (3, null, 1, '2020/05/17');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 6
	values (3, null, 1, '2020/04/28');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 7
	values (3, null, 2, '2019/08/05');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 8
	values (3, null, 2, '2020/05/17');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 9
	values (3, null, 2, '2020/02/11');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 10
	values (2, N'����������', null, null);
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 11
	values (10, null, 3, '2020/04/09');
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 12
	values (1, N'����������� ����', null, null);
insert into Orders(parent_id, group_name, customer_id, registered_at)	-- 13
	values (12, null, 4, '2020/06/25');


insert into OrderItems(order_id, name, price)
	values (4, N'�������', 30);
insert into OrderItems(order_id, name, price)
	values (4, N'����', 20);
insert into OrderItems(order_id, name, price)
	values (5, N'�������', 50);
insert into OrderItems(order_id, name, price)
	values (5, N'�������� �������', 40);
insert into OrderItems(order_id, name, price)
	values (5, N'����', 30);
insert into OrderItems(order_id, name, price)
	values (6, N'�������� �������', 30);
insert into OrderItems(order_id, name, price)
	values (6, N'�������� �������', 40);
insert into OrderItems(order_id, name, price)
	values (7, N'������������� �������', 50);
insert into OrderItems(order_id, name, price)
	values (7, N'�����������', 10);
insert into OrderItems(order_id, name, price)
	values (7, N'�������� �������', 60);
insert into OrderItems(order_id, name, price)
	values (8, N'�������', 50);
insert into OrderItems(order_id, name, price)
	values (8, N'�����������', 10);
insert into OrderItems(order_id, name, price)
	values (9, N'���������� �������', 50);
insert into OrderItems(order_id, name, price)
	values (9, N'�������� �������', 40);
insert into OrderItems(order_id, name, price)
	values (11, N'������', 2);
insert into OrderItems(order_id, name, price)
	values (11, N'�����', 1);
insert into OrderItems(order_id, name, price)
	values (13, N'�����', 100);
insert into OrderItems(order_id, name, price)
	values (13, N'������', 70);
insert into OrderItems(order_id, name, price)
	values (13, N'����', 20);
go
