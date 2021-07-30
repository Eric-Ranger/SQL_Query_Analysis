Select location_name, time_year,
	Sum(days_to_prod) As sum_days_prod,
	Rank() Over(Partition By time_year 
		Order By time_year, location_name) As Rank_days_prod
From delay_till_prod As d, w_time_d As t
Where d.contract_date = t.time_id
Group By location_name, time_year
