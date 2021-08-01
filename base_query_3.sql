Select j.job_id, j.Location_id, Location_name, t.time_year, t.time_month,
	Sum(cost_labor) As Sum_labor_cost, 
	Sum(cost_material) As Sum_material_cost, 
	Sum(cost_overhead) As Sum_overhead_cost,
	Sum(machine_hours)* Sum(rate_per_hour) As Sum_machine_cost, 
	Sum(cost_labor + cost_material + cost_overhead) + Sum(machine_hours * rate_per_hour) As Sum_total_cost, 
	Sum(quantity_produced) As Sum_qty_produced, 
	(Sum(cost_labor + cost_material + cost_overhead) + Sum(machine_hours * rate_per_hour))/Sum(quantity_produced) As Unit_cost
From w_job_f As j, w_location_d As l, w_time_d As t, w_sub_job_f As su, w_machine_type_d As m
Where j.location_id = l.location_id
	And j.job_id = su.job_id
	And su.machine_type_id = m.machine_type_id
	And j.contract_date = t.time_id
Group By j.job_id, j.Location_id, Location_name, t.time_year, t.time_month
Order by time_year, time_month
