**Amazon India Sales Performance Analytics**
**Project Overview**
This repository contains a complete end to end data analytics pipeline. My goal for this project was to analyze over 120,000 raw ecommerce records from Amazon India to uncover operational bottlenecks, track fulfillment efficiency, and visualize $78.59M in generated revenue.

Instead of just loading flat files into a visualization tool, I built this project to mirror a true enterprise workflow. I used SQL Server to extract and clean the messy raw data, imported the structured tables into Power BI for dimensional modeling, engineered dynamic DAX measures, and designed a modern executive web application interface.

Architecture and Workflow
**Phase 1: Database Extraction and ETL**
The raw dataset contained several data quality issues, including missing financial values, inconsistent boolean flags, and string based date columns. I utilized SQL Server Management Studio to build a robust cleaning pipeline.

I wrote the following T SQL script to create a clean production table. This script resolves missing revenue values by casting them to precise decimals, standardizes the date formats, and converts text based B2B flags into binary integers for faster filtering in the BI layer.

USE AmazonAnalytics;
GO

/* Drop the table if it already exists to allow safe reruns */
IF OBJECT_ID('cleaned_amazon_sales', 'U') IS NOT NULL
    DROP TABLE cleaned_amazon_sales;
GO

SELECT 
    [Order ID] AS order_id,
    [Category] AS category,
    [Size] AS size,
    [Status] AS order_status,
    [Fulfilment] AS fulfillment,
    [ship city] AS ship_city,
    [ship state] AS ship_state,
    
    /* Resolving financial data quality challenges */
    COALESCE(TRY_CAST([Amount] AS DECIMAL(10, 2)), 0.00) AS cleaned_amount,
    [Sales Channel ] AS sales_channel,
    
    /* Standardizing temporal and boolean data */
    TRY_CAST([Date] AS DATE) AS order_date,
    CASE
        WHEN [B2B] = 'True' THEN 1
        ELSE 0
    END AS is_b2b
    
INTO cleaned_amazon_sales
FROM raw_amazon_sales;
GO

**Phase 2: Data Modeling and DAX Engineering**
With the cleaned data imported into Power BI, I established the relational model and began engineering the metrics. I deliberately separated core financial performance from logistics health to give stakeholders a clear view of both gross sales and operational friction.

Core Financial Measures
To calculate the primary revenue drivers, I used aggregation and distinct counts to ensure multiple items in a single cart did not inflate the total order volume.

Total Revenue = SUM(cleaned_amazon_sales[cleaned_amount])

Total Orders = DISTINCTCOUNT(cleaned_amazon_sales[order_id])

Average Order Value = DIVIDE([Total Revenue], [Total Orders], 0)

Logistics and Defect Measures
I utilized the CALCULATE function to isolate specific order statuses. This allowed me to quantify exactly how much revenue was bleeding out of the pipeline due to merchant cancellations or transit losses.

Fulfillment Rate = 
DIVIDE(
    CALCULATE([Total Orders], cleaned_amazon_sales[order_status] = "Shipped"), 
    [Total Orders], 
    0
)

Cancellation Rate = 
DIVIDE(
    CALCULATE([Total Orders], cleaned_amazon_sales[order_status] = "Cancelled"), 
    [Total Orders], 
    0
)

Lost Revenue = 
CALCULATE(
    [Total Revenue], 
    cleaned_amazon_sales[order_status] IN {"Cancelled", "Returned", "Lost in Transit"}
)

**Phase 3: User Interface and Visual Engineering**
I spent a significant amount of time refining the UI and UX to ensure the dashboard looked like a custom built web application rather than a default spreadsheet report.

Optimizing the Data to Ink Ratio: I completely stripped away the redundant Y axis on the category bar chart and the X axis on the state chart. By placing clean data labels directly on the bars and rounding values to one decimal place, I eliminated visual clutter.

Unified Branding: I strictly enforced an Amazon inspired color palette. The canvas utilizes a soft #F4F5F7 background to allow the pure white #FFFFFF KPI cards to float using subtle drop shadows. All primary text and unselected buttons use a dark charcoal navy #232F3E, while key data points and active selections highlight in Amazon Orange #FF9900.

Custom Navigation Panel: I designed a dedicated white vertical panel on the far right of the canvas to house all user controls. I standardized the Customer Type, Order Status, and Fulfillment filters into uniform dropdown menus to save space. I also integrated a global Reset button powered by Power BI bookmarks, allowing executives to clear all active filters with a single click.

**Phase 4: Core Business Discoveries**
After finalizing the interactive elements, several key insights emerged from the data:

Regional Concentration: Maharashtra completely dominates regional sales, generating $13.3M in total revenue. Karnataka follows with $10.5M, while other states trail significantly.

Product Dominance: The traditional apparel categories drive the vast majority of volume. The Set and Kurta categories alone accounted for massive revenue shares, completely eclipsing smaller categories like Sarees and Dupattas.

The Logistics Bottleneck: While the overarching Fulfillment Rate sits at a healthy 85.01%, the Order Defect Rate is highly concerning at 17.43%. Furthermore, the business is bleeding $6.92M in Lost Revenue due to cancellations and returns, highlighting an immediate need to audit third party merchant shipping pipelines.


