
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(
  navbarPage(footer=
               fluidRow(
                 column(12, 
                        p("Source: US Social Security Administration 
                          (https://www.ssa.gov/OACT/babynames/)")
                        )
               ),
    title="Baby Names",
    tabPanel(
      title="Explore",
      titlePanel("Baby Names"),
      wellPanel(
        fluidRow(
          column(2,
                 numericInput("Year","Year:",value = 2014,min=1880,max=2014,step=1)
          ),
          column(2, 
                 selectInput("gender",label = "Gender:",choices=c("Boy"="Boy","Girl"="Girl"))
          ),
          column(3, 
                 uiOutput("topNames")
          ),
          column(3,
                 numericInput("clusNum","Clusters:",value=3, min = 3, max = 9,step=1)
          ),
          column(2,
                 numericInput("rankFilter","Max. Rank:",value = 250,min = 10, max=1000,step=1)
                 )
        )
      ),
      fluidRow(
        column(4,
               plotOutput("nameWC", height = "600px")
        ), 
        column(8,
               plotOutput("trendName",height="450px")
        )
      ),
      fluidRow(
        column(12,
               plotOutput("clusterPlot")
        )
      ),
      fluidRow(
        column(4,
               plotOutput("similarNames")
               )
      )
    ),
    #tabPanel(
    #  title="Name List",
    #  titlePanel("List"),
    #  fluidRow(
    #    column(12,
    #           wellPanel(
    #             
    #           )
    #    )
    #  ),
    #  fluidRow(
    #    column(12, 
    #           p("Listing Here!")
    #           )
    #  )
    #),
    tabPanel(
      title="Random Names",
      titlePanel("Random Name Generator"),
      fluidRow(
        column(12,
               wellPanel(
                 actionButton(inputId = "goRandom",label = "Generate Random Name",icon = icon("question-circle",lib = "font-awesome"))
               )
        )
      ),
      fluidRow(
        column(12, 
          uiOutput("randName")
        )
      )
    )#,
    #tabPanel(
    #  title="Potential Names",
    #  titlePanel("Permutations of Potential Names"),
    #  fluidRow(
    #    column(12,
    #           p("Something here")
    #           )
    #  )
    #)
  )
)
