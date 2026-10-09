USE AmazonAnalytics;
GO

/* Drop the table if it already exists to allow idempotent reruns */
IF OBJECT_ID('cleaned_amazon_sales', 'U') IS NOT NULL
    DROP TABLE cleaned_amazon_sales;
GO

SELECT 
    [Order ID] AS order_id,
    [Category] AS category,
    [Size] AS size,
    [Status] AS order_status,
    [Fulfilment] AS fulfillment,
    [ship-city] AS ship_city,
    [ship-state] AS ship_state,
    
    /* 1. Handle NULL financial records and enforce currency decimal precision */
    COALESCE(TRY_CAST([Amount] AS DECIMAL(10, 2)), 0.00) AS cleaned_amount,
    
    [Sales Channel ] AS sales_channel,
    
    /* 2. Standardize temporal records to standard SQL Date format */
    TRY_CAST([Date] AS DATE) AS order_date,
    
    /* 3. Convert string boolean flags into binary integers for indexing */
    CASE
        WHEN [B2B] = 'True' THEN 1
        ELSE 0
    END AS is_b2b

INTO cleaned_amazon_sales
FROM raw_amazon_sales;
GO

/* Create indexes for analytical query acceleration */
CREATE NONCLUSTERED INDEX IX_cleaned_amazon_sales_date ON cleaned_amazon_sales(order_date);
CREATE NONCLUSTERED INDEX IX_cleaned_amazon_sales_status ON cleaned_amazon_sales(order_status);
CREATE NONCLUSTERED INDEX IX_cleaned_amazon_sales_state ON cleaned_amazon_sales(ship_state);
GO
