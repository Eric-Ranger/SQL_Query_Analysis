Select j.Location_id, Location_name, j.sales_class_id, sales_class_desc, t.time_year, t.time_month, base_price,
Sum(quantity_ordered) As Sum_qty_ordered, Sum(unit_price * quantity_ordered) As Sum_job_amount
From w_job_f As j, w_location_d As l, w_sales_class_d As s, w_time_d As t
Where j.location_id = l.location_id
And j.sales_class_id = s.sales_class_id
And j.contract_date = t.time_id
Group By j.Location_id, Location_name, j.sales_class_id, sales_class_desc, t.time_year, t.time_month, base_price
Order By time_year, time_month
