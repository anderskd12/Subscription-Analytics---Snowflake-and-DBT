# Subscription-Analytics---Snowflake-and-DBT
Subscription Analytics - Snowflake and DBT
# Example Subscription Based Analytics dbt Project

A comprehensive data transformation pipeline for an example Saas subscription business, providing GAAP-compliant revenue recognition, churn analysis, and executive reporting capabilities.

## 📋 Project Overview

This dbt project transforms raw subscription and usage data into business-ready analytics tables, supporting financial reporting, customer success initiatives, and executive decision-making.

### Core Business Areas
- **Revenue Recognition**: GAAP-compliant monthly revenue tracking with deferred revenue calculations
- **Churn Analysis**: Multi-factor risk scoring and cohort retention analysis  
- **Financial Reporting**: ARR movements, MRR tracking, and growth metrics
- **Customer Analytics**: Lifetime value calculations and usage pattern analysis

## 🏗️ Data Architecture

### Source Tables
- **Customers**: Company profiles with size, industry, and acquisition channels
- **Subscription Plans**: Tailscale pricing tiers (Personal, Premium, Team, Business, Enterprise)
- **Subscriptions**: Customer subscriptions with billing cycles and user counts
- **Invoices**: Billing records with amounts, discounts, and payment status
- **Payments**: Stripe-like payment processing records
- **Usage Data**: Monthly device connections and data transfer metrics
- **Opportunities**: Salesforce-like sales pipeline data

### dbt Model Layers

#### 🧹 Staging Layer (`stg_*`)
Clean, typed raw data with consistent naming conventions and audit fields for data lineage.

#### ⚙️ Intermediate Layer (`int_*`)
Complex business logic including:
- Subscription metrics (MRR, ARR, churn scoring)
- GAAP-compliant revenue recognition
- Customer cohort analysis
- Churn prediction features

#### 📊 Marts Layer (`fct_*`, `dim_*`, `rpt_*`)
Business-ready tables for:
- Executive dashboards and reports
- Financial summary reporting
- Customer success workflows

## 🔑 Key Features

### 💰 Revenue Recognition
- **GAAP Compliance**: Monthly revenue recognition following accounting standards
- **Deferred Revenue**: Automated calculations for annual subscription billing
- **Revenue Waterfall**: Analysis of recognized vs. deferred revenue movements
- **Audit Trail**: Complete lineage for financial reporting requirements

### 📉 Churn Analysis
- **Multi-factor Scoring**: Combines payment behavior, usage patterns, and support interactions
- **Risk Categorization**: Automated classification (High/Medium/Low/Healthy)
- **Cohort Retention**: Time-based customer retention analysis
- **Early Warning System**: Proactive identification of at-risk customers

### 📈 Financial Reporting
- **ARR Movements**: Waterfall analysis of annual recurring revenue changes
- **MRR Tracking**: Monthly recurring revenue with growth comparisons
- **Customer LTV**: Lifetime value calculations by segment
- **Growth Metrics**: Month-over-month and year-over-year performance

## 🧪 Data Quality & Testing

### Automated Testing
- **Revenue Balance Tests**: Ensures recognition totals match invoice amounts
- **MRR Consistency**: Validates calculation logic across time periods
- **Referential Integrity**: Tests relationships between core business entities
- **Business Rule Validation**: Handles edge cases and data anomalies


# Generate documentation
dbt docs generate
dbt docs serve
```

## 📁 Project Structure

```
models/
├── staging/          # Raw data cleaning and typing
├── intermediate/     # Business logic and calculations
└── marts/
    ├── core/        # Core business entities
    ├── finance/     # Revenue and financial reporting
    └── reports/     # Executive dashboards
```

## 🤝 Contributing

1. Create feature branches from `main`
2. Follow existing naming conventions
3. Include tests for new models
4. Update documentation for significant changes
5. Ensure all tests pass before merging

## 📊 Key Metrics Available

- **Monthly Recurring Revenue (MRR)**
- **Annual Recurring Revenue (ARR)**
- **Customer Churn Rate**
- **Revenue Churn Rate**
- **Customer Lifetime Value (LTV)**
- **Customer Acquisition Cost (CAC)**
- **Net Revenue Retention (NRR)**

## 📞 Contact me

For questions or issues:
Check out my LinkedIn profile and shoot me a message!  Thanks for reading!
