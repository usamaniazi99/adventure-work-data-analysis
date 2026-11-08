# AdventureWorks Sales Dashboard (Power BI)

An interactive five page sales report built on Microsoft's fictional AdventureWorks sample data. It explores sales, profit, order volume, channels, customers, products, and seasonal patterns.

## Dashboard preview

![Summary dashboard](images/01-summary.png)

| Page | Question answered |
|---|---|
| Summary | How are sales, profit, and volume performing compared with last year? |
| Calendar | Which days and weekdays generate the most sales and orders? |
| Trend | How do monthly and recent sales, profit, and volume change over time? |
| YOY Analysis | How do results vary by product, channel, region, and reseller type? |
| Highlight Period | How does a selected date range compare with the rest of the year? |

![Calendar page](images/02-calendar.png)
![Year-over-year page](images/04-yoy.png)
![Highlight period page](images/05-highlight.png)

## Analysis and model

- Combined Internet and Reseller sales into a single Sales fact table in Power Query.
- Built a star schema with Date, Product, Customer, and Reseller dimensions.
- Added DAX measures for year-over-year change, rolling sales, top product share, and selected-period comparisons.
- Used a July–June fiscal year; the report opens on FY2013 (July 2012–June 2013).
- Capped calendar heatmap colors at the 90th percentile to keep outliers from dominating the view.

## Files

- Power BI report: AdventureWorks_Sales_Dashboard.pbix
- PDF export: docs/Adventure_Works.pdf
- Custom theme: theme/aw-warm-clay-v2.json
- Page screenshots: images/

Open the report in Power BI Desktop. The data is imported into the PBIX, so the report can be explored without connecting to the original database. Refreshing from SQL Server is optional; see the source notes in the PDF for details.

## Data note

This project uses Microsoft's fictional AdventureWorks sample data, covering December 2010 to January 2014. It does not represent a real company. Several fiscal years are partial, so comparisons should be interpreted with that in mind.

## Tools

Power BI Desktop · DAX · Power Query · SQL Server Express

**Author:** Muhammad Usama Khan · [LinkedIn](https://linkedin.com/in/u-niazi)
