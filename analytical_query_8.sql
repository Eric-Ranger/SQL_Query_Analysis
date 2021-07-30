Select X1.sales_class_desc, X1.year_invoice_sent, Sum_qty_returned, 
	(Sum_qty_returned::numeric/total_qty_returned::numeric) As qty_returned_over_total_qty
From(
	Select sales_class_desc, t.time_year As year_invoice_sent,
		Sum(quantity_shipped - invoice_quantity) As Sum_qty_returned
	From w_invoiceline_f As i, w_sales_class_d As s, w_time_d As t
	Where i.sales_class_id = s.sales_class_id
		And i.invoice_sent_date = t.time_id
	Group By sales_class_desc, t.time_year) As X1,
	
	(Select t.time_year As year_invoice_sent,
	 	Sum(quantity_shipped - invoice_quantity) As total_qty_returned
	From w_invoiceline_f As i, w_time_d As t
	Where i.invoice_sent_date = t.time_id
	Group By t.time_year) As X2
	
Where X1.year_invoice_sent = X2.year_invoice_sent
Order By X1.year_invoice_sent, sum_qty_returned
