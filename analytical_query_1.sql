Select Location_name, t.time_year, t.time_month, 
  Sum(unit_price)*Sum(quantity_ordered) As Sum_job_amount,
  SUM(Sum(unit_price)*Sum(quantity_ordered)) OVER(ORDER BY location_name, t.time_year,t.time_month 
	ROWS UNBOUNDED PRECEDING) AS CumSum_amount_ordered
From w_job_f As j, w_location_d As l, w_time_d As t
Where j.location_id = l.location_id
  And j.contract_date = t.time_id
Group By j.Location_id, Location_name, t.time_year, t.time_month
