use  hotel;
go
--1.1
select * from check_in
	order by date_start asc , time_leave desc ;


--1.2
select* from  client
	where gender =1;

select* from check_in 
	where time_leave >7 and time_leave <=14;

select* from booking 
	where preliminary_cost >10000;

--1.3
select count(*) as количество_комнат from room;

select max(total_cost ) as максимальна€_цена from check_in;

select id_client, sum(total_cost) as цена
from check_in
group by id_client;

select 
    number_room,
    min(total_cost) as мин_цена
from check_in
group by number_room;

--1.4
select 
    room.comfort  as тип_номера,
    room.floor_room  as этаж,
    count(*) as количество_номеров,
    sum(room.price) as сум_цен
from room 
group by rollup(room.comfort, room.floor_room);

select 
    room.comfort as тип_номера,
    count(*) as количество_номеров,
    avg(room.price) as средн€€_цена
 from room 
group by room.comfort;

select comfort, floor_room, sum(price) as сум_цен
from room
group by  cube (comfort, floor_room);

--1.5
select * 
from client 
where full_name NOT LIKE '%ова%';

----------------------------------

--2.1
select 
    client.full_name as клиент,   
    room.comfort as тип_номера   
from check_in , client , room 
where check_in.id_client = client.id_client
  and check_in.number_room = room.number_room;

select 
    client.full_name as клиент,
    room.number_room as номер
from booking , client , room 
where booking.id_client = client.id_client
  and booking.number_room = room.number_room;

--2.2
select 
    client.full_name as клиент,
    room.number_room as номер
from booking
inner join client on booking.id_client = client.id_client
inner join room on booking.number_room = room.number_room;

select 
    client.full_name as клиент,   
    room.comfort as тип_номера   
from check_in
inner join client on check_in.id_client = client.id_client
inner join room on check_in.number_room = room.number_room;

--2.3
select 
    client.full_name as клиент,
    room.number_room as номер,
    check_in.date_start as дата_заезда,
    check_in.date_end as дата_выезда
from client
left join check_in on client.id_client = check_in.id_client
left join room on check_in.number_room = room.number_room;

select 
    client.full_name as клиент,
    room.number_room as номер,
    booking.date_boofing as дата_брони,
    booking.time_leave as срок_брони
from client
left join booking on client.id_client = booking.id_client
left join room on booking.number_room = room.number_room;

--2.4
select 
    client.full_name as клиент,
    room.number_room as номер,
    booking.date_boofing as дата_брони
from booking
right join client on booking.id_client = client.id_client
right join room on booking.number_room = room.number_room;

select 
    room.number_room as номер,
    client.full_name as клиент,
    check_in.date_start as дата_заезда
from check_in
right join room on check_in.number_room = room.number_room
right join client on check_in.id_client = client.id_client;
-------------------------------------------
--2.5
select 
    room.comfort  as тип_номера,
    room.floor_room  as этаж,
    count(*) as rоличество_номеров,
    sum(room.price) as обща€_стоимость
from room 
group by rollup(room.comfort, room.floor_room);

select 
    room.comfort as тип_номера,
    count(*) as количество_номеров,
    avg(room.price) as средн€€_цена
from room 
group by room.comfort;

select comfort, floor_room, sum(price) as обща€_стоимость
from room
group by  cube (comfort, floor_room);


--2.6
select id_client, count(id_checkin) as количество_заселений
from check_in
group by id_client
having count(id_checkin) >1

select id_client, sum(total_cost) as обща€_стоимость
from check_in
group by id_client
having sum(total_cost) >10000

--2.7
select number_room
from check_in
where id_client in (
select id_client
from client
where full_name like '%ов%'
);

select full_name
from client 
where exists (
select 1
from booking 
where booking.id_client = client.id_client
);

select number_room, comfort
from room 
where not exists (
select 1
from check_in 
where check_in.number_room = room.number_room
);

--3.1
if object_id('Vi', 'V') is not null
    drop view Vi;
go
create view Vi as
select 
    client.full_name as клиент,   
    room.comfort as тип_номера   
from check_in
inner join client on check_in.id_client = client.id_client
inner join room on check_in.number_room = room.number_room;
--select * from Vi
go

if object_id('Vi', 'V') is not null
    drop view Vi;
go
create view Vi as
select 
    client.full_name as клиент,
    room.number_room as номер
from booking
inner join client on booking.id_client = client.id_client
inner join room on booking.number_room = room.number_room;
--select * from Vi
go
---------------------
--3.2

with client_costs as (
	select id_client, sum(total_cost) as обща€_стоимость
	from check_in
	group by id_client
)
select client.full_name, обща€_стоимость
from client_costs
inner join client on client_costs.id_client = client.id_client
where обща€_стоимость > 10000;

with booking_count as (
    select id_client, count(*) as кол_бронирований
    from booking
    group by id_client
)
select * from booking_count;

-- 4.1
select
row_number() over (order by full_name) as row_num,
full_name, passport
from client;

select
number_room, comfort, price,
rank() over (order by price desc) as price_rank
from room;

select
client.full_name,
count(check_in.id_checkin) as все_визиты,
dense_rank() over (order by count(check_in.id_checkin) desc) as визит_rank
from client 
left join check_in  on client.id_client = check_in.id_client
group by client.full_name;


select
comfort,
number_room,
price,
row_number() over (partition by comfort order by price desc) as номер_комфортности
from room;

select
    number_room,
    floor_room,
    comfort,
    row_number() over (partition by floor_room order by number_room) as номер_комнаты
from room;

select
comfort,
number_room,
price,
dense_rank() over (partition by comfort order by price desc) as ранг_цены
from room;

--5.1

select id_client from booking
intersect
select id_client from check_in
order by id_client;

select id_client from booking
except
select id_client from check_in
order by id_client;

select full_name from client
where id_client in (select id_client from booking)
union
select full_name from client
where id_client in (select id_client from check_in)
order by full_name;

--6.1

select
sum(case when gender = 1 then 1 else 0 end) as мужчины,
sum(case when gender = 0 then 1 else 0 end) as женщины
from client;


select
sum(case when comfort = 'Ёконом' then 1 else 0 end) as эконом,
sum(case when comfort = '—тандарт' then 1 else 0 end) as стандарт,
sum(case when comfort = 'Ћюкс' then 1 else 0 end) as люкс
from room;

select
client.full_name,
sum(check_in.total_cost) as обща€_сумма,
case
when sum(check_in.total_cost) >= 20000 then 'вип клиент'
when sum(check_in.total_cost) >= 10000 then 'посто€шка'
else 'редкий клиент'
end as категори€
from client 
left join check_in  on client.id_client = check_in.id_client
group by client.full_name;

-- 6.2
select *
from (
select comfort, floor_room
from room
) as a
pivot (
count(floor_room)
for comfort in ([эконом], [стандарт], [люкс])
) as b;


select *
from (
select case when gender = 1 then 'мужчина' else 'женщина' end as пол
from client
) as a
pivot (
count(пол)
for пол in ([мужчина], [женщина])
) as b;



select comfort_type, price_value
from (
select
sum(case when comfort = 'Ёконом' then price else 0 end) as эконом,
sum(case when comfort = '—тандарт' then price else 0 end) as стандарт,
sum(case when comfort = 'Ћюкс' then price else 0 end) as люкс
from room
) as a
unpivot (
price_value for comfort_type in ([эконом], [стандарт], [люкс])
) as a;