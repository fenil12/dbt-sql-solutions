# 🏗️ E-Commerce Analytics Data Warehouse (dbt Project)

This repository contains a **dbt project** that implements a **Kimball-style dimensional data warehouse** for **e-commerce analytics**.  
The project transforms raw operational and external data into a structured star schema to support **business intelligence**, **reporting**, and **advanced analytics**.

---

## 📊 Architecture Overview

**Data Flow:**
Raw Sources → Staging Layer → Core Dimensional Model → Business Marts


This layered architecture ensures data consistency, reusability, and analytical scalability.

---

## 🔍 Data Sources

| **Source**          | **Description**                           | **Key Tables**        |
|----------------------|-------------------------------------------|------------------------|
| Kafka Stream         | Real-time customer interaction events     | `kafka_stream`         |
| Product Data         | Product master and category information   | `product`, `product_category` |
| Sales Data           | Transactional sales records               | `sales_fact`           |
| Customer Data        | Customer master data                      | `customer`             |
| Subscription Data    | Customer subscription information         | `subscription_data`    |
| Weather Data         | External weather conditions data          | `weather_data`         |

---

## 🧱 Model Layers

### 1. **Staging Layer**
**Purpose:**  
Extract, clean, and standardize raw data from all source systems.

**Key Models:**  
`stg_kafka_stream`, `stg_products`, `stg_product_categories`, `stg_sales_fact`, `stg_customer`, `stg_subscriptions`, `stg_weather_data`

**Key Transformations:**
- Data type standardization  
- Null value handling  
- Basic data quality checks  
- Field renaming for consistency  

---

### 2. **Core Dimensional Model**
**Purpose:**  
Implements a **Kimball star schema** for analytical efficiency and consistency.

**Dimension Tables:**
- `dim_products` – Product dimension with inventory details  
- `dim_customer` – Customer dimension (SCD Type 2)  
- `dim_date` – Time-based analytical dimension  

**Fact Tables:**
- `fact_sales` – Sales transactions with revenue and quantity metrics  

---

### 3. **Business Marts**
**Purpose:**  
Business-domain focused models designed for stakeholder analysis.

**Financial Analytics**
- `product_category_revenue_monthly`  
- `product_revenue_payment_analysis`  
- `payment_method_preference`  
- `daily_revenue`  

**Customer Analytics**
- `customer_segments` – Tier classification, lifetime value, order frequency  

**Operational Analytics**
- `order_for_reviews` – Quality checks and business rule violations  

**Seasonal & Trend Analysis**
- `seasonal_sales_analysis` – Growth rate and volatility tracking  

---

## 💡 Key Business Capabilities

### Revenue Analysis
- Track revenue by category and subcategory  
- Analyze payment method performance  
- Monitor trends across daily, monthly, and quarterly periods  
- Evaluate gross profit and margins  

### Customer Insights
- Segment customers by value and activity  
- Calculate lifetime value  
- Assess subscription and purchasing behavior  

### Product Performance
- Monitor inventory and stock levels  
- Measure product category performance  
- Identify seasonal sales patterns  

### Operational Monitoring
- Detect anomalies in orders  
- Review discount and shipping policies  
- Evaluate rule compliance and risks  

### External Factor Analysis
- Correlate weather with sales behavior  
- Detect seasonal fluctuations and external impacts  

---

## ⚙️ Tech Stack

- **dbt** – Data transformation and modeling  
- **Snowflake / BigQuery / Redshift** – (configurable warehouse)  
- **GitHub Actions** – CI/CD automation (optional)  
- **Kafka** – Real-time event ingestion  

---

## 🚀 Getting Started

1. Clone the repository  
```bash
   git clone https://github.com/fenil12/dbt-sql-solutions.git
```
2. Setup virtual environment
```bash
source ci/setup.sh
```
3. Configure your profile in ~/profiles.yml
4. Run models
```bash
dbt run
```
5. Test data quality
```bash
dbt test
```
