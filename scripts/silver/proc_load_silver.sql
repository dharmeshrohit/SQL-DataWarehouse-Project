/*
===============================================================================
Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This script performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
===============================================================================
*/



-- Loading silver.crm_cust_info
truncate table silver.crm_cust_info;
insert into silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

select
cst_id,
cst_key,
trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status)) = 'M' then 'Married'
	 when upper(trim(cst_marital_status)) = 'S' then 'Single'
else 'n/a'
end cst_marital_status,
case when upper(trim(cst_gndr)) = 'F' then 'Female'
	 when upper(trim(cst_gndr)) = 'M' then 'Male'
else 'n/a'
end cst_gndr,
cst_create_date
from (
select *,
       row_number() over (
           partition by cst_id
           order by cst_create_date desc
       ) as flag_last
from bronze.crm_cust_info
where cst_id is not null
) where flag_last = 1


-- Loading silver.crm_prd_info
truncate table silver.crm_prd_info;
insert into silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)

select
prd_id,
replace(substring(prd_key, 1, 5), '-', '_') as cat_id, -- Extract category id
substring(prd_key, 7, length(prd_key)) as prd_key,     -- Extract product key
prd_nm,
coalesce(prd_cost, 0) as prd_cost,
case upper(trim(prd_line))
	when 'M' then 'Mountain'
	when 'R' then 'Road'
	when 'S' then 'Other sales'
	when 'T' then 'Touring'
	else 'n/a'
end as prd_line, -- Map product line codes to descriptive values
cast (prd_start_dt as date) as prd_start_dt,
cast (lead(prd_start_dt) over (
        partition by prd_key
        order by prd_start_dt
    ) - interval '1 day' as date) as prd_end_dt -- Calculate end date as one day before the next start date
from bronze.crm_prd_info


    -- Loading crm_sales_details
 truncate table silver.crm_sales_details;
 insert into silver.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)

select
sls_ord_num,
sls_prd_key,
sls_cust_id,
case
    when sls_order_dt = 0 or length(sls_order_dt::text) != 8 then null
    else sls_order_dt::text::date
end as sls_order_dt,
case
    when sls_ship_dt = 0 or length(sls_ship_dt::text) != 8 then null
    else sls_ship_dt::text::date
end as sls_ship_dt,
case
    when sls_due_dt = 0 or length(sls_due_dt::text) != 8 then null
    else sls_due_dt::text::date
end as sls_due_dt,
case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
		then sls_quantity * abs(sls_price)
	 else sls_sales	
end as sls_sales,
sls_quantity,
case when sls_price is null or sls_price <=0
		then sls_sales / nullif(sls_quantity, 0)
	 else sls_price
end as sls_price
from bronze.crm_sales_details


   -- Loading erp_cust_az12
truncate table silver.erp_cust_az12;
insert into silver.erp_cust_az12 (cid, bdate, gen)

select
case when cid like 'NAS%' then substring(cid, 4, length(cid)) -- Remove NAS prefix if present
	 else cid
end as cid,
case when bdate > now() then null 
	 else bdate
end as bdate,  -- Set future birthdates to NULL
case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
	 when upper(trim(gen)) in ('M', 'MALE') then 'Male'
	 else 'n/a'
end as gen -- Normalize gender values and handle unkown cases
from bronze.erp_cust_az12


    -- Loading erp_loc_a101
truncate table silver.erp_loc_a101;
insert into silver.erp_loc_a101(
cid,
cntry
)

select
replace(cid, '-', '') cid,
case when trim(cntry) = 'DE' then 'Germany'
	 when trim(cntry) in ('US', 'USA') then 'n/a'
	 when trim(cntry) = '' or cntry is null then 'n/a'
	 else trim(cntry)
end as cntry
from bronze.erp_loc_a101


    -- Loading erp_px_cat_g1v2
truncate table silver.erp_px_cat_g1v2;
insert into silver.erp_px_cat_g1v2(
id,
cat,
subcat,
maintenance
)

select
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2


