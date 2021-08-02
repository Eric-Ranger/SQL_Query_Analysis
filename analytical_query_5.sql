Select irs.job_id, irs.location_name, irs.time_year,
	round(Sum(sum_invoice_amt - sum_total_cost)/Sum(sum_invoice_amt)::numeric, 4) As profit_margin,
	round(Percent_RANK()OVER (
		ORDER BY (Sum(sum_invoice_amt - sum_total_cost)/Sum(sum_invoice_amt))DESC)::numeric,3) AS profit_Rank
From invoice_revenue_summary As irs, location_subjob_cost_summary As scs
Where irs.job_id = scs.job_id
Group By irs.job_id, irs.location_name, irs.time_year
