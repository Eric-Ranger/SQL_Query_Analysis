Select i.Location_id, Location_name, i.sales_class_id, sales_class_desc, t.time_year, t.time_month,
	Sum(quantity_shipped - invoice_quantity) As Sum_qty_returned,
	(Sum(invoice_amount)/Sum(invoice_quantity)) * Sum(quantity_shipped - invoice_quantity) As Sum_dollar_returned
From w_invoiceline_f As i, w_location_d As l, w_sales_class_d As s, w_time_d As t
Where i.location_id = l.location_id
	And i.sales_class_id = s.sales_class_id
	And i.invoice_sent_date = t.time_id
	And quantity_shipped > invoice_quantity
Group By i.Location_id, Location_name, i.sales_class_id, sales_class_desc, t.time_year, t.time_month
Order By time_year, time_month
