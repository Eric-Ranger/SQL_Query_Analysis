Select Location_name, t.time_year, t.time_month, 
	Sum(unit_price * quantity_ordered)::numeric(10,2) As Sum_job_amount,
	AVG(Avg(unit_price*quantity_ordered)) 
		OVER(Partition BY location_name ORDER BY time_year, time_month
		Rows Between 11 Preceding and CURRENT ROW)::numeric(10,2) As Moving_Average_job_amount
From w_job_f As j, w_location_d As l, w_time_d As t
Where j.location_id = l.location_id
	And j.contract_date = t.time_id
Group By Location_name, t.time_year, t.time_month
