Select location_name, t.time_year As year_date_shipped, 
	Sum(diff_bus_days) As sum_date_diff,
	Rank() Over(Partition By time_year Order By Sum(diff_bus_days) Desc),
		Dense_Rank() Over(Partition By time_year Order By Sum(diff_bus_days) Desc)
From first_shipment_delays_shipping As f, w_time_d As t
Where f.date_ship_by = t.time_id
Group By location_name, t.time_year
