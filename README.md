# 🚚 Supplier Reliability & Delivery Delay Analysis (SQL)

> Turning late deliveries from a vague frustration into measurable evidence.

![SQL](https://img.shields.io/badge/SQL-MySQL-blue)
![Status](https://img.shields.io/badge/status-complete-brightgreen)
![Focus](https://img.shields.io/badge/focus-supply%20chain%20analytics-orange)

---

## 📌 Project Overview

Late deliveries quietly raise operating costs, frustrate customers, and strain supplier relationships. This SQL project analyzes order and seller data to show **which suppliers deliver reliably and which do not**.

Using nine relational tables, the analysis compares each order's actual delivery date with its estimated delivery date. It measures:

- Late-delivery counts per seller
- On-time and late-delivery rates
- Average days late (delay severity)

It then breaks delays down by **product category**, **month and year**, and **seller state**, giving businesses clear evidence to monitor supplier performance, prioritize reliable sellers, and make better purchasing decisions.

## 🎯 Business Objectives

- Identify unreliable suppliers
- Analyze patterns in late deliveries
- Reduce operational costs caused by delays
- Support data-driven purchasing decisions

## 🗂️ Dataset

The database (`delays_analysis`) contains nine relational tables:

| Table | Description |
|---|---|
| `customers` | Customer information and location |
| `geolocation` | Zip-code level geographic data |
| `orders` | Order status and purchase / delivery / estimated-delivery timestamps |
| `order_items` | Items in each order, linked to products and sellers |
| `order_payments` | Payment details per order |
| `order_reviews` | Customer reviews and scores |
| `products` | Product attributes and category |
| `product_category_name_translation` | Category name translations |
| `sellers` | Seller information and location (city / state) |

**Key relationships**

```
orders ──< order_items >── products
                │
                └──────── sellers
```

## 🧰 Tools Used

- **MySQL** – querying and analysis
- **SQL concepts** – joins, aggregation, `CASE WHEN`, `COUNT(DISTINCT ...)`, date functions, filtering, grouping and ordering

## 🧹 Data Quality Checks

Before analysis, the data was checked for:

1. **Missing values** in `orders` (order ID, status, delivery date, estimated date)
2. **Missing seller / product information** in `order_items`
3. **Duplicate orders** (`GROUP BY order_id HAVING COUNT(*) > 1`)

Only orders with `order_status = 'delivered'` are used in the delay analysis.

## ❓ Analysis Questions

A delivery is considered **late** when `order_delivered_customer_date > order_estimated_delivery_date`.

| # | Question | Purpose |
|---|---|---|
| 1 | Which sellers have the highest number of late deliveries? | Find where delays are concentrated |
| 2 | What is each seller's on-time delivery rate? | Fair, volume-normalized comparison |
| 3 | What is each seller's average days late? | Measure delay *severity*, not just frequency |
| 4 | Which product categories have the most late deliveries? | Spot category-level logistics problems |
| 5 | How do late deliveries trend by month and year? | Reveal seasonality and peak periods |
| 6 | How do delays compare by seller state? | Identify regional hot spots |
| 7 | Which sellers have high late-delivery rates? | Shortlist sellers for review |

## 🔍 Example Queries

### Q1 – Sellers with the most late deliveries

```sql
SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS late_deliveries
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date >
        o.order_estimated_delivery_date
GROUP BY oi.seller_id
ORDER BY late_deliveries DESC
LIMIT 10;
```

### Q3 – Average days late per seller

```sql
SELECT
    oi.seller_id,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    )), 2) AS average_days_late
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date >
        o.order_estimated_delivery_date
GROUP BY oi.seller_id
ORDER BY average_days_late DESC;
```

### Q7 – Late-delivery rate per seller

```sql
SELECT
    oi.seller_id,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_rate
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY late_delivery_rate DESC;
```

The full set of queries is in [`SUPPLIER_RELIABILITY_SQL_PROJECT_ANALYSIS.sql`](./SUPPLIER_RELIABILITY_SQL_PROJECT_ANALYSIS.sql).

## 📊 Key Insights

> The charts in the accompanying report use **illustrative sample data**. Replace the placeholders below with the actual output of your queries.

- **Most late deliveries:** `<top seller IDs and counts from Q1>`
- **Lowest on-time rate:** `<sellers from Q2 / Q7>`
- **Most severe delays:** `<sellers with highest average days late from Q3>`
- **Worst categories:** `<top categories from Q4>`
- **Peak delay months:** `<months from Q5>`
- **Regional hot spots:** `<top states from Q6>`

**How to read the results**

- High late counts can simply reflect high order volume, so always read Q1 alongside the late-delivery rate (Q7).
- A seller can be late rarely but *very* late, so combine frequency (Q7) with severity (Q3).
- States with many sellers naturally show higher counts, so compare rates as well as totals.

## ✅ Recommendations

1. **Evaluate** – Build a monthly supplier scorecard covering on-time rate, late rate, and average days late.
2. **Prioritize** – Shift purchasing volume toward consistently reliable sellers.
3. **Intervene** – Set improvement targets for chronically late sellers and step in early.
4. **Prevent** – Use seasonal, category, and state patterns to fix delay drivers before peak periods, and set more realistic delivery estimates.

