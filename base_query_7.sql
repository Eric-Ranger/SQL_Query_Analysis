Select j.job_id, l.location_id, location_name, sa.sales_class_id, sales_class_desc, contract_date, Max(date_prod_begin) As first_prod_day,
	   Getbusdaysdiff(Max(date_prod_begin),contract_date) As days_to_prod
From w_job_f As j, w_location_d As l, w_sub_job_f As s, w_sales_class_d As sa
Where j.job_id =  s.job_id
	And j.location_id = l.location_id
	And j.sales_class_id = sa.sales_class_id
Group By j.job_id, l.location_id, location_name, sa.sales_class_id, sales_class_desc, contract_date
Having Getbusdaysdiff(Max(date_prod_begin),contract_date) > 20
