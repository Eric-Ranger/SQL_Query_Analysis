Select j.job_id, j.Location_id, Location_name, j.sales_class_id, sales_class_desc,
	   date_ship_by, X1.first_ship_date,
	   Getbusdaysdiff(X1.first_ship_date, date_ship_by) As diff_bus_days
From w_job_f As j, w_location_d As l, w_sales_class_d As s,
	
	(Select sub.job_id As job, Min(actual_ship_date) As first_ship_date
		From w_sub_job_f As sub, w_job_shipment_f As ship
		Where sub.sub_job_id = ship.sub_job_id
		Group By sub.job_id) As X1
	
Where j.location_id = l.location_id
	And j.sales_class_id = s.sales_class_id
	And j.job_id = X1.job
	And date_ship_by < X1.first_ship_date
Group By j.job_id, j.Location_id, Location_name, j.sales_class_id, sales_class_desc,
		date_ship_by, X1.first_ship_date
Order By Getbusdaysdiff(X1.first_ship_date, date_ship_by)
