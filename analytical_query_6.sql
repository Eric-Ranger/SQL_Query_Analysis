Select job_id, location_name, time_year, time_month, profit_margin, Cum_Dist_CarryCost
FROM
	( SELECT *, 
	 	CUME_DIST() OVER(ORDER BY profit_margin) As Cum_Dist_CarryCost
	  FROM per_rank_job_margins) X
WHERE Cum_Dist_CarryCost >= .95
