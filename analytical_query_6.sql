Select X1.job_id, X1.location_name, X1.time_year, X1.time_month, 
	round(X1.profit_margin::numeric,4) As profit_margin, round(X1.profit_margin_percent_rank::numeric,2) As percent_rank
From
	(Select job_id, location_name, time_year, time_month, profit_margin,
	 		Percent_Rank() Over(Order by profit_margin) As profit_margin_percent_rank
	 From profit_margin_rank) As X1
Where profit_margin_percent_rank > .95
