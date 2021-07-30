Select j.job_id, j.Location_id, Location_name, unit_price, quantity_ordered, t.time_year, t.time_month,
	Sum(invoice_amount) As Sum_invoice_amt, Sum(invoice_quantity) As Sum_invoice_qty
From w_job_f As j, w_location_d As l, w_invoiceline_f As i, w_time_d As t, w_sub_job_f As su, w_job_shipment_f As sh
Where j.location_id = l.location_id
	And j.job_id = su.job_id
	And su.sub_job_id = sh.sub_job_id
	And sh.invoice_id = i.invoice_id
	And j.contract_date = t.time_id
Group By j.job_id, j.Location_id, Location_name, unit_price, quantity_ordered, t.time_year, t.time_month
Order by time_year, time_month
