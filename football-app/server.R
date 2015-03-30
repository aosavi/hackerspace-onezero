## Read in the competition scores
rank = read.csv("competition_points.csv")

# changing some column names
colnames(rank)[1] = "Teams"
rank[,1] = gsub("[12]","",rank[,1])
colnames(rank)[4] = "League"
# setting the factor variable to character and rounding the scores
rank[,4] = sapply(rank[,4], function(x) as.character(x))
rank[,2] = round(rank[,2], digits = 1)
rank[,3] = round(rank[,3], digits = 1)

## Reading in the outlier data
outlier = read.csv("outlier_points.csv",stringsAsFactors = FALSE)

## So we have the number of points per league and year to make home points equal to away points
# We now scale this so multiply by number of matches
library(shiny)
library(dplyr)
require(data.table)
library(ggplot2)
shinyServer(function(input, output) {
  
  getDataName <- reactive({
    input$choice
  })
  
  getData <- reactive({
    if (getDataName() == "rank" || getDataName() == "outlier") 
    {
      out <- tryCatch(
        get(getDataName()),
        error = function(e) return(NULL))
    }
    else  out <- NULL
    
    return (out)
  })
  
  getDataVarNames <- reactive({
    dataFrame = getData()
    if (class(dataFrame) == "data.frame") out <- colnames(dataFrame)
    else out <- NULL
    return (out)
  })
  
  outputButton1 <- reactive({
    input$country      
  })
  
  outputButton2 <- reactive({
    input$season
  })
  
  outputButton3 <- reactive({
    input$ranking
  })
  
  getRank <- reactive({
    if (getDataName() == "rank"){
      data = getData()
      country = outputButton1()
      season = outputButton2()
      data = data[grep(paste(country,"_",season,sep=""), data$League),]
      rank1 = rank(-data[,2])
      rank2 = rank(-data[,3])
      rank_tot = rank1 - rank2
      data$rank_tot = floor(rank_tot)
      return (data)
    }
  })
  
  outputFilterRank <- reactive({
    if (getDataName() == "rank"){
      data <- getData()
      if (outputButton3() == "new_points"){
        data <- data[,c(1,3,4)]
        country<- outputButton1()
        season <- outputButton2()
        data = data[grep(paste(country,"_",season,sep=""), data$League),]
        data = arrange(data, desc(data[,2]))
        out <- data
      }
      else if (outputButton3() == "old_points"){
        data <- data[,c(1,2,4)]
        country<- outputButton1()
        season <- outputButton2()
        data = data[grep(paste(country,"_",season,sep=""), data$League),]
        data = arrange(data, desc(data[,2]))
        out <- data
      }
      else if (outputButton3() == "difference"){
        data = getRank()
        out <- data[,c(1,5)]
      }      
    }
    return (out)
  })
    
    
  
  outputTable <- reactive({    
    if (input$choice == "rank"){
      out <- outputFilterRank()
    }
    else out <- NULL
    return (out)
  })
  
  output$mytable <- renderDataTable({
    outputTable()
  })
  
  ### Now make the outlier data
  outputFilter2 <- reactive({
    if (input$choice == "outlier"){
      data1 <- getData()
      if (input$season1 == "all")
      {
        country = input$country1
        data1 = data1[grep(paste("data","_",country,sep=""), data1$league),]
      }
      else 
      {
        country = input$country1
        season = input$season1
        data1 = data1[grep(paste("data","_",country,"_",season,sep=""), data1$league),]
      }
    }
    else data1 <- NULL
    return (data1)
  })
  
  scatterPlot <- reactive({
    if (input$choice == "outlier"){
      data <- outputFilter2()
      varNames <- getDataVarNames()
      if (input$season1 != "all"){
        out <- ggplot(
          data = data, 
          aes_string(
            x = varNames[2],
            y = varNames[3],
            label = varNames[1])) +
          geom_point() +
          geom_text(size = 3) +
          geom_abline(intercept = 0, slope = 1) +
          ylab("points away") + xlab("home points") +
          theme_bw()
      }
      else
      {
        out <- ggplot(
          data = data, 
          aes_string(
            x = varNames[2],
            y = varNames[3],
            label = varNames[1])) +
        geom_point() +
        geom_text(size = 3, alpha = 0.6) +
        geom_abline(intercept = 0, slope = 1) +
        ylab("points away") + xlab("home points") +
        theme_bw() +
        facet_wrap(~league, ncol = 3, scales = "free")
      }
    }
    else out <- NULL
    return (out)
  })
  
  
  output$myPlot <- renderPlot({
    print(scatterPlot())
  })
  
  }
)