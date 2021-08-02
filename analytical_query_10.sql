Select location_name, time_year As year_date_promised, 
	Count(*) As count_delayed_jobs,
	Sum(diff_bus_days) As sum_diff_days,
	round(Sum(quantity_ordered - shipped_qty)/ Sum(quantity_ordered)::numeric,4) As Delay_rate,
	Rank() Over(Partition By time_year 
		Order By sum(quantity_ordered - shipped_qty)/ Sum(quantity_ordered) Desc) As Rank_delay_rate
From last_ship_delays_promised As l, w_time_d As t
Where l.date_promised = t.time_id
Group By location_name, time_year
