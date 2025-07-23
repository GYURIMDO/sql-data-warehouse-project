
/******************************************************************************************
 * Script:        Gold Layer - Dimensional Views Creation
 * Description:   This script creates views for the gold layer: dim_customers, dim_products,
 *                and fact_sales. It includes surrogate keys, joins between CRM and ERP
 *                data, and filters for current product records.
 * Author:        [Your Name]
 * Date:          [Insert Date]
 ******************************************************************************************/

-- ===========================
-- GOLD VIEW: dim_customers
-- ===========================


IF OBJECT_id(gold.dim_customers, 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
CREATE VIEW gold.dim_customers AS (

	SELECT 
		ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE
			WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender info
			ELSE COALESCE(ca.gen, 'n/a')
		END AS gender,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date

	
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca ON ca.cid = ci.cst_key
	LEFT JOIN silver.erp_loc_a101 la ON la.cid = ci.cst_key

)

------------------------------------------------------

IF OBJECT_id(gold.dim_products, 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
CREATE VIEW gold.dim_products AS (
	SELECT 
		ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_id) AS product_key, -- want to sort by start dt and take the uniqueness of prd_id
		pn.prd_id AS product_id,
		pn.prd_key AS product_number,
		pn.prd_nm AS product_name,
		pn.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenance,
		pn.prd_cost As cost,
		pn.prd_line AS product_line,
		pn.prd_start_dt As start_date
	
	FROM silver.crm_prd_info pn
	LEFT JOIN silver.erp_px_cat_g1v2 pc ON pc.id = pn.cat_id
	WHERE pn.prd_end_dt IS NULL -- Filter out all historical data
)
----------------------------------------------------------
IF OBJECT_id(gold.fact_sales, 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
CREATE VIEW gold.fact_sales AS (
	SELECT 
		sd.sls_ord_num AS order_number,
		pr.product_key,
		cu.customer_key,
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price

	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers cu ON cu.customer_id = sd.sls_cust_id
)

