<style>
blockquote { font-size: 14px; }
</style>
### Background

The **Economic Order Quantity (EOQ)** model is a classic model in production
scheduling.  It results in the optimal order quantity that should be purchased 
with each order to minimize the cost of holding excess inventory and the cost of 
placing orders.  Its derivation can be found [here](https://en.wikipedia.org/wiki/Economic_order_quantity#The_Total_Cost_function_and_derivation_of_EOQ_formula).

The **Economic Production Quantity (EPQ)** model is an extension of the EOQ 
model that assumes that the company will produce its own inventory.  Its 
derivation can be found [here](https://en.wikipedia.org/wiki/Economic_production_quantity#Total_Cost_function_and_derivation_of_EPQ_formula).

Assuming a company has the capability of either purchasing or producing its
goods, the total annual cost of both the EOQ and EPQ models can be calculated
and compared in order to facilitate build vs. buy decision-making.

Extensions to both models that allow for inclusion of shortage (stockout) and 
back-ordering costs, as well as minimum order quantities (MOQ) and quantity
discounts, but these are outside the scope of this tool.

### Assumptions

From Tersine p. 95:

> 1. The demand rate is known, constant, and continuous.
> 2. The lead time is known and constant.
> 3. The entire lot size is added to inventory at the same time.
> 4. No stockouts are permitted; since demand and lead time are known, stockouts
>    can be avoided.
> 5. The cost structure is fixed; order/setup costs are the same regardless of 
>    lot size, holding cost is a linear function based on average inventory, and 
>    unit purchase cost is constant (no quantity discounts).
> 6. There is sufficient space, capacity, and capital to procure the desired 
>    quantity.
> 7. The item is a single product; it does not interact with other inventory 
>    items (there are no joint orders).

### Parameters

* $Q^*$: Optimal order quantity (for EOQ) or the optimal production quantity (for 
         EPQ)
* $C$: cost per order independent of quantity (i.e., shipping and handling for 
       EOQ and production setup cost for EPQ)
* $R$: annualized demand $R$
* $P$: unit cost (purchase price (for EOQ) or production price (for EPQ))
* $H$: annual holding cost per unit (cost of warehouse space, insurance, etc.;
       expressed as a specified percent $F$ of $P$ ).  
* $p$: daily production rate (units produced per day for EPQ;  $p \geq
       \frac{R}{250}$  (assuming 250 working days per year)
* $r$: daily demand rate (units demanded per day for EPQ)

### Formulas (Tersine 92-95, 121-123)

**Holding Cost**

* $H = PF$

**Economic Order Quantity and Total Cost:**

* EOQ:  $$Q^* = \sqrt{\frac{2CR}{H}}$$
* Total Annual Cost (Annual Demand Cost + Annual Holding Cost): 
  $$TC(Q^*) = PR + HQ^* = PR + \sqrt{2CRH}$$ 

**Economic Production Quantity and Total Cost:**

* EPQ: $$Q^* = \sqrt{\frac{2CRp}{H(p - r)}}$$
* Total Annual Cost:  $$TC(Q^*) = PR + \frac{HQ^*(p-r)}{p} = \frac{\sqrt{2CRH}(p-r)}{p}$$

**Economic Order Interval and Number of Annual Orders (for both EOQ and EPQ):**

* Economic Order Interval (EOI):  $$T^* = \frac{Q^*}{R} = \sqrt{\frac{2C}{RH}}$$
* Number of Orders per Year = $$m^* = \frac{1}{T^*} = \frac{R}{Q^*} = \sqrt{\frac{RH}{2C}}$$
