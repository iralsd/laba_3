use  hotel;
go

--a  Найти номера, не занятые и не забронированные на данный момент
select 
    room.number_room as свободные_номера
from room 
where room.number_room not in (
	select number_room from check_in
	where getdate() between check_in.date_start and check_in.date_end
	) 
	and room.number_room  not in (
	select number_room from booking
	where getdate() between booking.date_boofing and dateadd(day, booking.time_leave, booking.date_boofing )
	);

--b Найти клиентов, выехавших из номера раньше срока, указанного в договоре
select 
    client.full_name as клиент,
    check_in.number_room as номер,
    datediff(day, check_in.date_start, check_in.date_end) as прожил,
    booking.time_leave as хотел_прожить
from booking, check_in, client 
where booking.id_client = check_in.id_client
  and client.id_client = booking.id_client
  --and check_in.number_room = booking.number_room
  and check_in.date_start = booking.date_boofing
  and datediff(day, check_in.date_start, check_in.date_end) < booking.time_leave

--с Найти номера, которые ни разу не сдавались с начала текущего года
select number_room as номер
from room
where number_room NOT IN (
    select number_room 
    from check_in
    where year(date_start) = year(getdate())
);

--d Найти клиентов, забронировавших номер, но так и не въехавших в него
select client.full_name as клиент
from client
where id_client in (select id_client from booking)
  and id_client not in (
    select booking.id_client
    from booking
    join check_in on booking.id_client = check_in.id_client
    where check_in.date_start between booking.date_boofing 
                                and dateadd(day, booking.time_leave, booking.date_boofing)
  );

--e Среди всех клиентов, наиболее часто пользующихся услугами гостиницы, найти клиентов с максимальным сроком проживания
with client_stats as (
    select 
        client.id_client as id,
        client.full_name as клиент,
        (select count(*) 
         from check_in 
         where check_in.id_client = client.id_client) as количество_заселений,
        (select sum(datediff(day, date_start, date_end)) 
         from check_in 
         where check_in.id_client = client.id_client) as общий_срок_проживания
    from client
),
max_checkins as (
    select max(количество_заселений) as max_checkins
    from client_stats
),
top_clients as (
    select *
    from client_stats
    where количество_заселений = (select max_checkins from max_checkins)
),
max_stay as (
    select max(общий_срок_проживания) as max_days
    from top_clients
)
select *
from top_clients
where общий_срок_проживания = (select max_days from max_stay)
order by клиент;
