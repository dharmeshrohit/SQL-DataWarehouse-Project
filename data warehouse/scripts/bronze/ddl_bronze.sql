/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


create schema if not exists bronze;


drop table if exists bronze.crm_cust_info;
create table bronze.crm_cust_info (
    cst_id              integer,
    cst_key             varchar(50),
    cst_firstname       varchar(50),
    cst_lastname        varchar(50),
    cst_marital_status  varchar(50),
    cst_gndr            varchar(50),
    cst_create_date     date
);


drop table if exists bronze.crm_prd_info;
create table bronze.crm_prd_info (
    prd_id       integer,
    prd_key      varchar(50),
    prd_nm       varchar(50),
    prd_cost     integer,
    prd_line     varchar(50),
    prd_start_dt timestamp,
    prd_end_dt   timestamp
);


drop table if exists bronze.crm_sales_details;
create table bronze.crm_sales_details (
    sls_ord_num  varchar(50),
    sls_prd_key  varchar(50),
    sls_cust_id  integer,
    sls_order_dt integer,
    sls_ship_dt  integer,
    sls_due_dt   integer,
    sls_sales    integer,
    sls_quantity integer,
    sls_price    integer
);


drop table if exists bronze.erp_loc_a101;
create table bronze.erp_loc_a101 (
    cid    varchar(50),
    cntry  varchar(50)
);


drop table if exists bronze.erp_cust_az12;
create table bronze.erp_cust_az12 (
    cid    varchar(50),
    bdate  date,
    gen    varchar(50)
);


drop table if exists bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2 (
    id           varchar(50),
    cat          varchar(50),
    subcat       varchar(50),
    maintenance  varchar(50)
);