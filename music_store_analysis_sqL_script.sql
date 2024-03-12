-- Q1. Who is the senior most employee based on job title?
Select * from employee
order by levels desc 
limit 1;

-- Q2. Which Counrty has the most Invoices ? 
Select count(*) as c , billing_country 
from invoice
group by billing_country
order by c desc ;

-- Q3. What are the top 3 values of total invoice?
select total
from invoice
order by total desc
limit 3;

-- Q4. Which city has the best customers?
--  We would like to throw a promotional Music Festival in the city 
--  we made the most money.Write a query that returns one city 
--  that has the highest sum of invoice totals. 
--  Return both the city name & sum of all invoice totals
select sum(total) as total_invoice ,billing_city
from invoice
group by billing_city
order by total_invoice desc ;

-- Q5.Who is the best customer? 
--  The customer who has spent the most money will be declared the best customer.
--  Write a query that returns the person who has spent the most money. 
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- Q6.Write query to return the email,first name,last name,
--  & Genre of all Rock Music listeners.
--  Return Your list ordered alphabetically by email starting with A  
select distinct email,first_name,last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in (
      select track_id
      from track
      join genre on track.genre_id = genre.genre_id
      where genre.name like 'Rock'
      )
order by email;

-- Q7.Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name 
-- and total track count of the top 10 rock bands
select artist.artist_id ,artist.name,count(artist.artist_id) as number_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id,artist.name
order by number_of_songs desc
limit 10;

-- Q8.Returns all track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first.
 select name,milliseconds
 from track
 where milliseconds > (
       select avg(milliseconds) as avg_track_length
       from track)
order by milliseconds desc;

-- Q9. Find how much amount spent by each customer on artists? 
-- Write a query to return customer name,artist name and total_spend
with best_selling_artist as(
     select artist.artist_id as artist_id,artist.name as artist_name,
     sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
     from invoice_line
     join track on track.track_id=invoice_line.track_id
     join album on album.album_id=track.album_id
     join artist on artist.artist_id = album.album_id
     group by artist_id,artist_name
     order by total_sales desc
     limit 1
	)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by c.customer_id,c.first_name,c.last_name,bsa.artist_name
order by amount_spent desc;


-- Q10. Write a query that determines the customer 
-- that has spent the most on music for each country.
-- Write a query that returns the counrty along with the top customer and 
-- how much they spend. for countries where the top 
-- amount spent is shared,provide all customers who spend this amount
with Customer_with_country as (
     select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
     row_number() over(partition by billing_country order by sum(total) desc) as rowno
     from invoice
     join customer on customer.customer_id=invoice.customer_id
     group by customer.customer_id,first_name,last_name,billing_country
     order by billing_country asc, total_spending desc)
select * from customer_with_country where rowno <=1 ;