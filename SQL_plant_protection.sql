-- SQL Excellence Bootcamp Graduating Project of Cicek Akkaya:

create database PlantProtection
use PlantProtection

create table Farmers(
	FarmerID int identity(1,1) primary key,
	First_Name nvarchar(100),
	Last_Name nvarchar(100),
	E_mail nvarchar(100),
	FarmerRegisterDate date
)
	

create table Pesticides(
	PesticideID int identity(1,1) primary key,
	PesticideName nvarchar(100),
	PlantName nvarchar(100),
	Price decimal(10,2)
)


create table Orders(
	OrderID int identity(1,1) primary key,
	OrderDate date,
	Quantity int,
	FarmerID int foreign key (FarmerID) references Farmers(FarmerID),
	PesticideID int foreign key (PesticideID) references Pesticides(PesticideID)
)


-- I created all the tables. Now, I am assigning random datas to theese tables.

declare @i int = 1;
declare @First_Name nvarchar(100);
declare @Last_Name nvarchar(100);
declare @E_mail nvarchar(100);
declare @FarmerRegisterDate date;

declare @Names table (First_Name nvarchar(100));
insert into @Names values
('Narin'), ('Okan'), ('Emel'), ('Kemal'), ('Kenan'), ('Hakan'), ('Necati'), ('Melahat'), ('Mehmet'), ('Ahmet'), ('Leyla'), ('Sema')

declare @Surnames table (Last_Name nvarchar(100));
insert into @Surnames values
('Akkaya'), ('Temel'), ('Demir'), ('Koral'), ('Arslan'), ('Akan'), ('Su'), ('Canan'), ('Salih'), ('Kaya'), ('Kara'), ('Emir')

declare @StartDate date = '2018-01-01';
declare @EndDate date = '2024-10-01';

declare @TotalDays int = datediff(day, @StartDate , @EndDate);

while @i <= 100000
begin 
	select top 1 @First_Name = First_Name from @Names order by newid();
	select top 1 @Last_Name = Last_Name from @Surnames order by newid();
	set @E_mail = lower(@First_Name) + '.' + lower(@Last_Name) + cast(@i as nvarchar(10)) + '@example.com';
	set @FarmerRegisterDate = dateadd(day,floor(rand()* @TotalDays), @StartDate);
	insert into Farmers(First_Name, Last_Name, E_mail, FarmerRegisterDate)
	values (@First_Name, @Last_Name, @E_mail, @FarmerRegisterDate);
	set @i = @i + 1;
	end



select count(*) from Farmers


--I am doing the same processing to all table. It's Pesticides table's turn.


declare @i int = 1;
declare @PesticideName nvarchar(100);
declare @Plant nvarchar(100);
declare @Price decimal(10,2);

declare @Pesticide_Names table (PesticideName nvarchar(100));
insert into @Pesticide_Names values
('Spinosaad'), ('Abamectin'), ('Pyriproxyfen'), ('Fenoxycarb'),('Dazomet'), ('Etaxozole'),
('Buprofezin'), ('Indoxacarb'), ('Spirotetramat'), ('Azadirachtin'), ('Deltamethrin'), ('Bacillus thuringiensis')

declare @Plant_Names table (PlantName nvarchar(100));
insert into @Plant_Names values
('Apple/Elma'), ('Tangerine/Mandalin'), ('Lemon/Limon'), ('Tomato/Domates'), ('Pepper/Biber'), ('Eggplant/Patl�can'),
('Avacado/Avacado'), ('Walnut/Ceviz'), ('Orange/Portakal'), ('Lettuce/Marul'), ('Parsley/Maydanoz'), ('Onion/So�an')

while @i <= 100001
begin
	select top 1 @PesticideName = PesticideName from @Pesticide_Names order by newid();
	select top 1 @Plant = PlantName from @Plant_Names order by newid();
	set @Price = round(rand()*(2000-350)+10,2);
	insert into Pesticides(PesticideName,PlantName,Price)
	values (@PesticideName,@Plant,@Price)
	set @i = @i + 1;
	end


select count(*) from Pesticides


UPDATE Pesticides SET PesticideName = 'Spinosad' WHERE PesticideName = 'Spinosaad'


--I have written Spinosad pesticide's name wrongly. I have updated all the database the true state of this pesticide. 


--It's Orders tables' turn to assign random datas.

declare @i int = 1;
declare @OrderDate date;
declare @Quantity int;
declare @FarmerID int;
declare @PesticideID int;

declare @Starting_Date date = '2018-01-01';
declare @Ending_Date date = '2024-10-01';

declare @Total_Days int = datediff(day,@Starting_Date,@Ending_Date);

while @i <= 100000
begin
	set @OrderDate = dateadd(day,floor(rand()*@Total_Days),@Starting_Date);
	set @Quantity = floor(rand()*50)+1;
	set @FarmerID = floor(rand()*100000)+1;
	set @PesticideID = floor(rand()*100001)+1;

	insert into Orders(OrderDate, Quantity, FarmerID, PesticideID)
	values (@OrderDate, @Quantity, @FarmerID, @PesticideID)
	set @i = @i + 1;
	end


select count(*) from Orders


--I am generating a strored procodure which makes executes the orders between 2 dates that specified.

create procedure sp_OrdersForDate
    @Start_Time date,
    @End_Time date
as
begin
    select *
    from Orders
    where OrderDate BETWEEN @Start_Time AND @End_Time
end


--Now, I am calling this procedure.

exec sp_OrdersForDate '2020-01-01', '2020-01-02'


-- I am generating another procedure. ( This procedure sorts orders from bigger quantity to smaller ones for between two date specified.)

create procedure sp_OrderbyQuantityForDate
	@Starts_Time date,
	@Ends_Time date
as
begin
	select *
	from Orders
	where OrderDate BETWEEN @Starts_Time AND @Ends_Time
	order by Quantity DESC
end


--I am calling the second procedure.

exec sp_OrderbyQuantityForDate '2020-01-01','2020-01-02'


--I am generating a view that executes each farmers' total order quantity.

create view vw_TotalOrderQuantityForFarmer AS
SELECT
    F.First_Name + ' ' + F.Last_Name AS FarmerName,
    SUM(O.Quantity) AS TotalOrder
FROM
    Orders O
INNER JOIN Farmers F ON O.FarmerID = F.FarmerID
GROUP BY
    F.FarmerID, F.First_Name, F.Last_Name



--I am calling this view.

select * from vw_TotalOrderQuantityforFarmer


--I am generating an index.

set statistics time on

select * from Pesticides where PlantName = 'Tangerine/Mandalin'


/*When we execute upper and down indexed queries, we can see that the down indexed query 
executes more faster than upper indexed query. */

create nonclustered index Tangerine_Pesticides

on Pesticides (PlantName)

select * from Pesticides where PlantName = 'Tangerine/Mandalin'

set statistics time off
