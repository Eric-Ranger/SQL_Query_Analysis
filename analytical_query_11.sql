Select Location_name, time_year,
	count(*) As count_jobs_delay,
	Sum(diff_bus_days) As ship_days_delay,
	Sum(shipped_qty) As sum_qty_delay,
	Rank() Over (Partition By time_year
		Order By Sum(Shipped_qty) Desc) as Rank_qty_delayed
From last_ship_delays_promised As l, w_time_d As t
Where l.date_promised = t.time_id
Group By location_name, time_year
