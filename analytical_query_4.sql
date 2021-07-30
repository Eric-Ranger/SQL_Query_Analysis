Select irs.location_name, irs.time_year,
	(Sum(sum_invoice_amt) - Sum(sum_total_cost))/Sum(sum_invoice_amt As profit_margin,
	RANK()OVER (PARTITION BY irs.time_year 
		ORDER BY ((Sum(sum_invoice_amt) - Sum(sum_total_cost))/(Sum(sum_invoice_amt)))DESC) AS profit_Rank
From invoice_revenue_summary As irs, location_subjob_cost_summary As scs
Where irs.job_id = scs.job_id
Group By irs.location_name, irs.time_year