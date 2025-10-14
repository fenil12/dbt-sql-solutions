{% docs __overview__ %}
# Project Overview

This dbt project implements a comprehensive Kimball dimensional data warehouse for e-commerce analytics. The project processes raw data from multiple sources into a structured star schema optimized for business intelligence and analytical queries.

# Architecture
## Data Flow 
Raw Sources → Staging Layer → Dimensional Model → Business Marts

# Data Sources 

| **Source**          | **Description**                           | **Key Tables**        |
|----------------------|-------------------------------------------|------------------------|
| Kafka Stream         | Real-time customer interaction events     | `kafka_stream`         |
| Product Data         | Product master and category information   | `product`, `product_category` |
| Sales Data           | Transactional sales records               | `sales_fact`           |
| Customer Data        | Customer master data                      | `customer`             |
| Subscription Data    | Customer subscription information         | `subscription_data`    |
| Weather Data         | External weather conditions data          | `weather_data`         |

# Model Layers
## 1. Staging Layer  

**Purpose:**  
Raw data extraction, basic cleaning, and standardization.

### Models
- **stg_kafka_stream** – Customer interaction events from Kafka  
- **stg_products** – Product master data  
- **stg_product_categories** – Product categorization and inventory  
- **stg_sales_fact** – Sales transactions  
- **stg_customer** – Customer information  
- **stg_subscriptions** – Subscription records  
- **stg_weather_data** – Weather conditions  

### Key Transformations
- Data type standardization  
- Null value handling  
- Basic data quality checks  
- Field renaming for consistency  

## 2. Core Dimensional Model  

**Purpose:**  
Kimball star schema design for optimized analytics and reporting.  

### Dimension Tables  
- **dim_products** – Product dimension with inventory status  
- **dim_customer** – Customer dimension with SCD Type 2 support  
- **dim_date** – Date dimension for time-based analysis  

### Fact Tables  
- **fact_sales** – Sales transactions with revenue metrics  

---

## 3. Business Marts  

**Purpose:**  
Domain-specific analytical models designed for business users to enable targeted insights.  

### Financial Analytics  
- **product_category_revenue_monthly** – Monthly revenue by category  
- **product_revenue_payment_analysis** – Revenue with payment method breakdown  
- **payment_method_preference** – Payment method performance  
- **daily_revenue** – Daily revenue trends with moving averages  

### Customer Analytics  
- **customer_segments** – Customer value segmentation  
  - Tier-based classification (High / Medium / Low Value)  
  - Lifetime value calculations  
  - Order frequency analysis  

### Operational Analytics  
- **order_for_reviews** – Flagged orders for quality review  
  - Business rule violations (high discounts, shipping costs)  

### Seasonal & Trend Analysis  
- **seasonal_sales_analysis** – Monthly and quarterly trend analysis  
  - Growth rate calculations  
  - Sales volatility measurement  

---

## Key Business Capabilities  

### 1. Revenue Analysis  
- Track revenue by product category and subcategory  
- Analyze payment method preferences  
- Monitor daily, monthly, and quarterly trends  
- Calculate profit margins and gross profit  

### 2. Customer Insights  
- Segment customers by spending behavior  
- Track customer lifetime value  
- Analyze purchase patterns and frequency  
- Monitor subscription performance  

### 3. Product Performance  
- Monitor inventory status  
- Perform stock level analysis  
- Evaluate product category performance  
- Identify seasonal product trends  

### 4. Operational Monitoring  
- Ensure order quality assurance  
- Analyze discounts and shipping cost impact  
- Enforce business rule compliance  
- Conduct risk assessments  

### 5. External Factor Analysis  
- Identify seasonal patterns  
- Perform external correlation analysis  

{% enddocs %}