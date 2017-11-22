library(shiny)
## printCurrency function from here:
## http://s.mylesandmyles.info/R-functions-and-such/printCurrency/printCurrency.html
## this is overkill for the usage here but it works.
## based on this Stack Overflow response:
## http://stackoverflow.com/questions/14028995/money-representation-in-r/23833928#23833928
printCurrency <-
    function(value, currency.sym = "$", digits = 2, sep = ",",
             decimal = ".", multiplier = 1, mult.sym = "")
    {
        mult.sym <- ifelse(multiplier == 10 ^ 1, " tens",
                           ifelse(
                               multiplier == 10 ^ 2, "H",
                               ifelse(
                                   multiplier == 10 ^ 3, "K",
                                   ifelse(multiplier == 10 ^ 6, "M",
                                          ifelse(multiplier == 10 ^ 9, "B",
                                                 ""))
                               )
                           ))
        paste(
            currency.sym, formatC(
                value / multiplier, format = "f",
                big.mark = sep, digits = digits,
                decimal.mark = decimal
            ),
            mult.sym, sep = ""
        )
    }

## unit holding cost function -- holding cost = holding cost % * unit cost
unit_holding <- function(holding_cost_percent, unit_cost) {
    ## if holding_cost_percent = 0, forcing it to be 0.001 to avoid division
    ## by zero
    ifelse(holding_cost_percent == 0, 0.001, holding_cost_percent) * unit_cost
}

## economic order quantity function
eoq <-
    function(demand, order_cost, holding_cost_percent, unit_cost) {
        sqrt(2 * order_cost * demand / unit_holding(holding_cost_percent,
                                                    unit_cost))
    }

## economic order interval function
eoi <-
    function(demand, order_cost, holding_cost_percent, unit_cost) {
        sqrt(2 * order_cost / (unit_holding(holding_cost_percent, unit_cost) *
                                   demand))
    }

## calculate daily demand rate assuming 250 working days per year
demand_rate <- function(demand) {
    demand / 250
}

## economic production quantity function
epq <-
    function(demand, order_cost, holding_cost_percent, unit_cost,
             production_rate) {
        sqrt(2 * order_cost * demand * production_rate /
                 (
                     unit_holding(holding_cost_percent, unit_cost) *
                         (production_rate - demand_rate(demand))
                 ))
    }

## process user's inputs and calculate EOQ/EPQ
shinyServer(function(input, output) {
    ##
    ## EoQ CALCULATIONS
    ##
    
    ## calculate the cost of holding one unit
    eoqholding <-
        reactive({
            as.numeric(unit_holding(
                input$holding_cost_percent_eoq / 100,
                input$unit_cost_eoq
            ))
        })
    
    ## calculate EOQ
    eoqopt <- reactive({
        as.numeric(
            eoq(
                input$demand_eoq,
                input$order_cost_eoq,
                input$holding_cost_percent_eoq / 100,
                input$unit_cost_eoq
            )
        )
    })
    
    ## display EOQ
    output$eoqty <-
        renderText(
            paste(
                "EOQ =", round(eoqopt(), 2),
                "units.  Assuming partial units cannot
                be ordered, each order should be for",
                ceiling(eoqopt()), "units."
            )
        )
    
    ## calculate EOI for EOQ's inputs
    eoqeoi <- reactive({
        as.numeric(
            eoi(
                input$demand_eoq,
                input$order_cost_eoq,
                input$holding_cost_percent_eoq / 100,
                input$unit_cost_eoq
            )
        )
    })
    
    ## display EOI
    output$eoq_eoi <-
        renderText(
            paste(
                "Economic Order Interval (EOI) =",
                round(eoqeoi(), 4), "years (i.e.,
                place",
                round(1 / eoqeoi(), 1), "orders per
                year or one order every",
                round(eoqeoi() * 365, 1), "days))"
            )
)
    
    ## calculate total annual cost of demand (total annual unit cost)
    eoqdemandcost <- reactive({
        as.numeric(input$unit_cost_eoq *
                       input$demand_eoq)
    })
    
    ## display annual unit cost
    output$eoqannualdemandcost <-
        renderText(paste(
            "Annual Unit Cost = ",
            printCurrency(eoqdemandcost(), digits = 2)
        ))
    
    ## calculate the annual holding cost
    eoqholdingannual <-
        reactive({
            as.numeric(sqrt(
                2 * input$order_cost_eoq * input$demand_eoq
                * unit_holding(
                    input$holding_cost_percent_eoq / 100,
                    input$unit_cost_eoq
                )
            ))
        })
    
    ## display the annual holding cost
    output$eoqannualholding <-
        renderText(paste(
            "Annual Holding Cost =",
            printCurrency(eoqholdingannual(), digits = 2)
        ))
    
    ## calculate the total annual cost (demand cost + holding cost)
    eoqtotcost <-
        reactive({
            as.numeric(eoqdemandcost() + eoqholdingannual())
        })
    
    ## display total annual cost of EOQ
    output$eoqtotalcost <-
        renderText(paste("Total Annual Cost =",
                         printCurrency(eoqtotcost(), digits = 2)))
    
    ## display EOQ inputs
    output$eoqdemand <-
        renderText(paste("Annual Demand =", input$demand_eoq,"units"))
    output$eoqunitcost <-
        renderText(paste(
            "Unit Purchase Cost =", printCurrency(input$unit_cost_eoq,
                                                  digits = 0)
        ))
    output$eoqordercost <- renderText(paste(
        "Order Cost =",
        printCurrency(input$order_cost_eoq,
                      digits = 0)
    ))
    output$eoqholdingcostpercent <-
        renderText(paste0("Holding Cost % = ",
                          input$holding_cost_percent_eoq,
                          "%"))
    output$eoqholdingcost <-
        renderText(
            paste(
                "Holding Cost per Unit =",
                printCurrency(
                    input$unit_cost_eoq
                    * input$holding_cost_percent_eoq
                    / 100, digits = 2
                ), "(unit purchase cost * holding cost %)"
            )
        )
    
    ##
    ## EPQ CALCULATIONS
    ##
    
    ## calculate the cost of holding one unit
    epqholding <-
        reactive({
            as.numeric(unit_holding(
                input$holding_cost_percent_epq / 100,
                input$unit_cost_epq
            ))
        })
    
    ## calculate EPQ
    epqopt <- reactive({
        as.numeric(
            epq(
                input$demand_epq,
                input$order_cost_epq,
                input$holding_cost_percent_epq / 100,
                input$unit_cost_epq,
                input$production_rate
            )
        )
    })
    
    ## display EPQ
    output$epqty <- renderText(
        paste(
            "EPQ =",
            round(epqopt(), 2), "units.  Assuming partial units cannot be
            produced, each production run should be for",
            ceiling(epqopt()), "units."
        )
    )
    
    ## calculate EOI for EPQ's inputs
    epqeoi <- reactive({
        as.numeric(
            eoi(
                input$demand_epq,
                input$order_cost_epq,
                input$holding_cost_percent_epq / 100,
                input$unit_cost_epq
            )
        )
    })
    
    ## display EOI
    output$epq_eoi <-
        renderText(
            paste(
                "Economic Order Interval (EOI) =",
                round(epqeoi(), 4), "years (i.e., produce",
                round(1 / epqeoi(), 1), "lots per year or one lot every",
                round(epqeoi() * 365, 1), "days)"
            )
        )
    
    ## calculate total annual cost of demand (total annual unit cost)
    epqdemandcost <- reactive({
        as.numeric(input$unit_cost_epq *
                       input$demand_epq)
    })
    
    ## display annual unit cost
    output$epqannualdemandcost <-
        renderText(paste(
            "Annual Unit Cost = ",
            printCurrency(epqdemandcost(), digits = 2)
        ))
    
    ## calculate the annual holding cost
    epqholdingannual <-
        reactive({
            as.numeric(
                sqrt(
                    2 * input$order_cost_epq * input$demand_epq
                    * unit_holding(
                        input$holding_cost_percent_epq / 100,
                        input$unit_cost_epq
                    )
                ) * (
                    input$production_rate - demand_rate(input$demand_epq)
                ) / input$production_rate
            )
        })
    
    ## display the annual holding cost
    output$epqannualholding <-
        renderText(paste(
            "Annual Holding Cost =",
            printCurrency(epqholdingannual(), digits = 2)
        ))
    
    ## calculate the total annual cost (demand cost + holding cost)
    epqtotcost <-
        reactive({
            as.numeric(epqdemandcost() + epqholdingannual())
        })
    
    ## display total annual cost of EOQ
    output$epqtotalcost <-
        renderText(paste("Total Annual Cost =",
                         printCurrency(epqtotcost(), digits = 2)))
    
    ## display EPQ inputs
    output$epqdemand <-
        renderText(paste("Annual Demand =", input$demand_epq,
                         "units"))
    output$epqunitcost <-
        renderText(paste(
            "Unit Production Cost =", printCurrency(input$unit_cost_epq,
                                                    digits = 0)
        ))
    output$epqordercost <-
        renderText(paste(
            "Order Cost =", printCurrency(input$order_cost_epq, digits = 0)
        ))
    output$epqholdingcostpercent <-
        renderText(paste0("Holding Cost % = ", input$holding_cost_percent_epq,
                          "%"))
    output$epqholdingcost <-
        renderText(
            paste(
                "Holding Cost per Unit =", printCurrency(
                    input$unit_cost_epq * input$holding_cost_percent_epq / 100,
                    digits = 2
                ),
                "(unit purchase cost * holding cost %)"
            )
        )
    output$epqproductionrate <-
        renderText(paste("Production Rate =", input$production_rate))
    output$epqdemandrate <-
        renderText(
            paste(
                "Demand Rate =", input$demand_epq / 250, "(annual demand / 250
                working days per year)"
        )
            )
})
