require(markdown)
library(shiny)
shinyUI(
    navbarPage(
        "EOQ & EPQ Calculators",
        inverse = TRUE,
        tabPanel(
            "EOQ",
            ## EOQ parameters
            sidebarPanel(
                h4('Please enter the following parameters:'),
                numericInput(
                    'demand_eoq', 'Annual Demand', 1000, min = 50, 
                    max = 1000000, step = 50
                ),
                numericInput(
                    'unit_cost_eoq', 'Unit Purchase Cost', 5, min = 1, 
                    max = 5000, step = 1
                ),
                numericInput(
                    'order_cost_eoq', 'Cost per Order (Shipping & Handling)', 
                    10, min = 1, max = 100, step = 1
                ),
                sliderInput(
                    'holding_cost_percent_eoq', 'Holding Cost as a Percent of 
                    Unit Cost', min = 0, max = 25, value = 10, step = 1, 
                    post = "%"
                ),
                submitButton('Calculate Optimal Order Quantity')
            ),
            ## EOQ calculations
            mainPanel(
                h3('Economic Order Quantity (EOQ):'),
                textOutput("eoqty"),
                
                h3('Based on these Inputs:'),
                textOutput("eoqdemand"),
                textOutput("eoqunitcost"),
                textOutput("eoqordercost"),
                textOutput("eoqholdingcostpercent"),
                textOutput("eoqholdingcost"),
                
                h3('Order Interval and Cost:'),
                textOutput("eoq_eoi"),
                textOutput("eoqtotalcost"),
                textOutput("eoqannualdemandcost"),
                textOutput("eoqannualholding")
            )
        ),
        tabPanel(
            "EPQ",
            ## EPQ parameters
            sidebarPanel(
                h4('Please enter the following:'),
                numericInput(
                    'demand_epq', 'Annual Demand', 1000, min = 50, 
                    max = 1000000, step = 50
                ),
                numericInput(
                    'unit_cost_epq', 'Unit Production Cost', 5, min = 1, 
                    max = 5000, step = 1
                ),
                numericInput(
                    'order_cost_epq', 'Cost per Order (Setup Cost)', 10, 
                    min = 1, max = 100, step = 1
                ),
                sliderInput(
                    'holding_cost_percent_epq', 'Holding Cost as a Percent of 
                    Unit Cost', 0.01, min = 0, max = 25, value = 10, step = 1,
                    post = "%"
                ),
                numericInput(
                    'production_rate', 'Production Rate per Day (must be greater
                    than Annual Demand / 250)', 5, min = 1,
                    max = 100000, step = 5
                ),
                submitButton('Calculate Optimal Production Quantity')
            ),
            ## EOQ calculations
            mainPanel(
                h3('Economic Production Quantity (EPQ)'),
                textOutput("epqty"),
                
                h3('Based on these Inputs:'),
                textOutput("epqdemand"),
                textOutput("epqunitcost"),
                textOutput("epqordercost"),
                textOutput("epqholdingcostpercent"),
                textOutput("epqholdingcost"),
                textOutput("epqproductionrate"),
                textOutput("epqdemandrate"),
                
                h3('Order Interval and Cost:'),
                textOutput("epq_eoi"),
                textOutput("epqtotalcost"),
                textOutput("epqannualdemandcost"),
                textOutput("epqannualholding")
                
            )
        ),
        ## about this tool
        tabPanel(
            "About",
            sidebarPanel(includeMarkdown("side.md")),
            mainPanel(withMathJax(),
                      includeMarkdown("about.md"))
        ),
        ## instructions for using this tool
        tabPanel(
            "Instructions",
            sidebarPanel(includeMarkdown("side.md")),
            mainPanel(withMathJax(),
                      includeMarkdown("instructions.md"))
        )
    )
)