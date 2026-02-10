# adventureworks-business-sql
Business-focused analytical SQL queries on the AdventureWorks dataset using CTEs, window functions, and dimensional logic.

📊 **SQL Analytics Case Studies (AdventureWorks2025 OLTP)**

**Overview**

This repository contains a focused set of SQL case studies built on the **AdventureWorks2025 OLTP database**.
The goal is not to demonstrate SQL syntax in isolation, but to showcase analytical thinking, business problem framing, and decision-oriented querying using production-style data.

Each query answers a realistic business question that a data analyst or analytics engineer would be expected to solve in interviews or on the job.
---

**What This Portfolio Demonstrates:**

- Translating business questions into SQL logic
- Using window functions for fairness, ranking, and time-based analysis
- Maintaining row-level granularity while deriving aggregate insights
- Writing SQL that scales beyond “toy answers”
- Explaining why a query is written a certain way, not just what it returns
- This portfolio intentionally avoids gimmicks and focuses on clarity, correctness, and reasoning.

---

**Case Studies Included:**

**1. Revenue Churn Analysis**

Question:

Which customers are reducing or stopping purchases, and how does churn evolve over time?

What the query shows:
- Customer-level behavior changes
- Revenue impact of churn, not just customer counts
- How analytical SQL supports retention strategy discussions



**2. Month-over-Month (MoM) Growth**

Question:

How is revenue trending month-over-month, and where are growth slowdowns occurring?

What the query shows:
- Time-series analysis using window functions
- Comparison logic without collapsing the dataset
- How analysts identify early signs of growth deceleration



**3. Fair Ranking Using Window Functions**

Question:

Who are the top-performing entities within their own departments, not globally?

What the query shows:
- Why DENSE_RANK() with partitioning is often more correct than subqueries
- Fair comparisons across organizational units
- Handling outliers like executives without skewing results



**4. Year-to-Date (YTD) Performance Tracking**

Question:

How is the business performing cumulatively throughout the year?

What the query shows:
- Running totals using window functions
- Time-aware analytics used in executive reporting
- How YTD metrics differ from simple aggregates



**5. Sales Matrix / Multi-Dimensional Analysis**

Question:

How do sales perform across products, regions, and time simultaneously?

What the query shows:
- Multi-dimensional thinking without relying on PIVOT
- Clean, extensible SQL suitable for BI tools
- Preparing data for dashboards rather than static reports

---

**Design Philosophy**
- **Business-first:** Every query starts with a real decision-making question.
- **Window functions over hacks:** Chosen for correctness, scalability, and flexibility.
- **Readable SQL:** Structured for humans, not just databases.
- **Explainable logic:** Each query can be defended verbally in interviews.

This repository reflects how SQL is actually used in analytics roles:
to **support reasoning, challenge assumptions, and drive decisions**

---

**How to Use This Repository**

- Review queries individually. Each file is self-contained.
- Focus on the question being answered, not just the output.
- Ideal for:
    - SQL interview discussions
    - Analytical case study walkthroughs
    - Demonstrating problem-solving approach

---

**Final Note**

This portfolio is intentionally concise.

Depth of thinking > volume of queries.

---
