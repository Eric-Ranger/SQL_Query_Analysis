Select sales_class_desc, t.time_year As year_invoice_sent,
	Sum(quantity_shipped - invoice_quantity) As Sum_qty_returned,
	Rank() OVER(Partition By t.time_year Order By(Sum(quantity_shipped -invoice_quantity))Desc)
From w_invoiceline_f As i, w_sales_class_d As s, w_time_d As t
Where i.sales_class_id = s.sales_class_id
	And i.invoice_sent_date = t.time_id
	And quantity_shipped > invoice_quantity
Group By sales_class_desc, t.time_year
