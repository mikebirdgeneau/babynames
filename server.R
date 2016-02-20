
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(wordcloud)
library(RColorBrewer)
library(data.table)
library(ggplot2)
library(stringdist)

shinyServer(function(input, output) {

  output$nameWC <- renderPlot({
    message(input$gender)
    
    plotData <- us_baby_names[Gender == as.character(input$gender) & Rank<=min(c(as.numeric(input$rankFilter),100)) & Year == input$Year,]
    wordcloud(plotData$Name,plotData$Percent,colors = brewer.pal(n = 9,ifelse(input$gender=="Boy","GnBu","PuRd")),min.freq = 0,max.words = 90,scale=c(3,0.3))
  })
  
  output$topNames <- renderUI({
    choices <- us_baby_names[Gender == as.character(input$gender) & Rank<=input$rankFilter & Year == input$Year]
    setkeyv(choices, c("Rank"))
    list(selectInput("trendName","Name:",choices=choices$Name,multiple = TRUE,selectize = TRUE))
  })
  
  output$trendName <- renderPlot({
    plotTrendData <- us_baby_names[Name %in% input$trendName & Gender == input$gender,]
    ggplot(plotTrendData,aes(x=Year,y=Percent,colour=as.factor(Name)))+geom_line()+geom_point()+theme_bw()
  })
  
  getClusterData <- reactive({
    input$gender
    input$clusNum
    input$rankFilter
    isolate({
    getCluster(gender = input$gender,k = input$clusNum,maxRank = as.numeric(input$rankFilter))
    })
  })

  
  output$clusterPlot <- renderPlot({
    plotData<-getClusterData()
    
    ggplot(plotData,aes(x=Year,y=Percent,group=Name))+geom_line(alpha=0.5)+facet_wrap(~Cluster,scales = "free_y")+geom_line(data=plotData[Name %in% input$trendName,],aes(colour=Name),lwd=0.7)+theme_bw()+scale_color_discrete(name="Name")+theme(legend.position="bottom")
    
  })
  
  getRandomName <- reactive({
    input$goRandom
    
    isolate({
    temp <- us_baby_names[Gender == input$gender & Rank<= input$rankFilter,]
    return(temp[sample(x = 1:nrow(temp),size = 1),])
    })
  })
  
  output$randName <- renderUI({
    fluidRow(
      column(6,
        h2(getRandomName()$Name)     
      )
    )
    
  })
  
  output$similarNames <- renderPlot({
    input$trendName
    isolate({
      namelist <- tolower(us_baby_names[Gender==input$gender,]$Name)
    namedist <- stringdist(tolower(input$trendName),tolower(namelist),method="osa")
    wordcloud(unique(namelist[namedist<=1]),colors = brewer.pal(n = 9,ifelse(input$gender=="Boy","GnBu","PuRd")),min.freq = 0,max.words = 90,scale=c(3,0.3))
    })
  })
  
})
