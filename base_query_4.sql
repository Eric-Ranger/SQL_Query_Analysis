SELECT i.location_id, l.location_name, i.sales_class_id, s.sales_class_desc, su.machine_type_id, m.machine_model, t.time_year, t.time_month,
    Sum(i.quantity_shipped - i.invoice_quantity) AS sum_qty_returned,
    Sum(i.invoice_amount) / sum(i.invoice_quantity)::numeric * sum(i.quantity_shipped - i.invoice_quantity)::numeric AS sum_dollar_returned
FROM w_invoiceline_f i, w_location_d l, w_sales_class_d s, w_time_d t, w_sub_job_f su, w_machine_type_d m, w_job_shipment_f sh
WHERE i.location_id = l.location_id 
	AND i.sales_class_id = s.sales_class_id 
	AND i.invoice_sent_date = t.time_id
	AND su.sub_job_id = sh.sub_job_id
	AND i.invoice_id = sh.invoice_id
	AND su.machine_type_id = m.machine_type_id
	AND i.quantity_shipped > i.invoice_quantity
GROUP BY i.location_id, l.location_name, i.sales_class_id, s.sales_class_desc, su.machine_type_id, m.machine_model, t.time_year, t.time_month
ORDER BY t.time_year, t.time_month;

