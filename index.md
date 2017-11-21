---
title       : EOQ & EPQ Calculators
subtitle    : Web-based Economic Order Quantity & Economic Production Quantity Calculation
author      : Steve Myles
job         : January 2016
output      : html_document
---

## Background

* **Economic Order Quantity (EOQ)**
 * a classic model in production scheduling
 * results in the optimal order quantity that should be purchased with each order 
   to *minimize the total cost*
  * **total cost** = the cost of holding excess inventory plus the cost of 
    placing orders
* **Economic Production Quantity (EPQ)**
 * an extension of the EOQ model that assumes that the company will produce its 
   own inventory
* There is [a new online EOQ & EPQ Calculator](https://scumdogsteev.shinyapps.io/eoq-epq) ([GitHub repo](https://github.com/scumdogsteev/eoq-epq))
 * based on user inputs, this tool calculates the EOQ and EPQ as well as related
   costs
* Extensions to both models exist that allow for inclusion of shortage 
  (stockout) and back-ordering costs, as well as minimum order quantities (MOQ)
 * these extensions are outside the scope of this tool

--- 

## Formulas

* **EOQ** and **EPQ** are both functions of annualized demand $R$, cost per 
order $C$ (not dependent on the quantity ordered), unit cost $P$ (price for EOQ,
production cost for EPQ), and holding cost $H$ (defined as a percentage $F$ of 
unit cost, so $H = PF$)
* Additionally, **EPQ** is a function of production rate (units produced per day) 
$p$ and demand rate (daily demand) $r$
* Derivations:  [EOQ](https://en.wikipedia.org/wiki/Economic_order_quantity#The_Total_Cost_function_and_derivation_of_EOQ_formula) | [EPQ](https://en.wikipedia.org/wiki/Economic_production_quantity#Total_Cost_function_and_derivation_of_EPQ_formula)

* EOQ:  $$Q^* = \sqrt{\frac{2CR}{H}} = \sqrt{\frac{2CR}{PF}}$$
* EPQ:  $$Q^* = \sqrt{\frac{2CRp}{H(p - r)}}$$

---

## Economic Order Quantity Example


```r
eoq <- function(demand, order_cost, holding_cost_percent, unit_cost) { 
    sqrt(2 * order_cost * demand / 
        ## avoid division by 0 by setting 0% holding cost to 0.001     
        (ifelse(holding_cost_percent == 0, 0.001, holding_cost_percent) * unit_cost)) }
demand <- 1000; order_cost <- 10; holding_cost_percent <- 0.1; unit_cost <- 5
eoqty <- eoq(demand, order_cost, holding_cost_percent, unit_cost)
eoqty
```

```
## [1] 200
```

* For the above scenario, the EOQ is 200
* If this reflected the need to order a partial unit, one would need to round up
  to meet demand

---

## Economic Production Quantity Example


```r
demand_rate <- function(demand) {demand / 250}
epq <- function(demand, order_cost, holding_cost_percent, unit_cost, production_rate) {
    sqrt(2 * order_cost * demand * production_rate /
            ((ifelse(holding_cost_percent == 0, 0.001, holding_cost_percent) 
              * unit_cost) * (production_rate - demand_rate(demand)))) }
production_rate <- 5 ## the other parameters are the same as those in the EOQ example
epqty <- epq(demand, order_cost, holding_cost_percent, unit_cost, production_rate)
epqty
```

```
## [1] 447.2136
```

* For the above scenario, the EPQ is 447.2
* Each production run should be 448 in this case (assuming
  partial units cannot be produced)
