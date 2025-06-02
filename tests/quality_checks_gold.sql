/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- checking 'gold.dim_customers'
-- ====================================================================

-- check for uniqueness of customer key in gold.dim_customers
-- expectation: no results 
select 
    customer_key,
    count(*) as duplicate_count
from gold.dim_customers
group by customer_key
having count(*) > 1;

-- ====================================================================
-- checking 'gold.dim_products'
-- ====================================================================

-- check for uniqueness of product key in gold.dim_products
-- expectation: no results 
select 
    product_key,
    count(*) as duplicate_count
from gold.dim_products
group by product_key
having count(*) > 1;

-- ====================================================================
-- checking 'gold.fact_sales'
-- ====================================================================

-- check the data model connectivity between fact and dimensions
select * 
from gold.fact_sales f
left join gold.dim_customers c
on c.customer_key = f.customer_key
left join gold.dim_products p
on p.product_key = f.product_key
where p.product_key is null or c.customer_key is null;
