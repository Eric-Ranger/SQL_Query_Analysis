Select j.job_id, j.Location_id, Location_name, j.sales_class_id, sales_class_desc, Quantity_ordered,
	X1.shipped_qty, date_promised, last_ship_date,
	Getbusdaysdiff(last_ship_date, date_promised) As diff_bus_days
From w_job_f As j, w_location_d As l, w_sales_class_d As s,
	
	(Select sub.job_id As job, Max(actual_ship_date) As last_ship_date, Sum(actual_quantity) As shipped_qty
		From w_job_f As job, w_sub_job_f As sub, w_job_shipment_f As ship
		WHERE job.job_id = sub.job_id
		And sub.sub_job_id = ship.sub_job_id
		And date_promised < actual_ship_date
		Group By sub.job_id) As X1
	
Where j.location_id = l.location_id
	And j.sales_class_id = s.sales_class_id
	And j.job_id = X1.job
	And date_promised < last_ship_date
Group By j.job_id, j.Location_id, Location_name, j.sales_class_id, sales_class_desc, 
		 date_promised, quantity_ordered,X1.last_ship_date, X1.shipped_qty
Order By j.job_id
