library(shiny)
# read tags_name
tags_names <- read.csv("data/tagsname.csv",stringsAsFactors = F,header = T)$tagName

shinyUI(fluidPage(
  titlePanel("stack"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Find Trend and Growth rate for StackOverflow Tags"),
      # textInput("tags","Enter tag name","search"),
      selectInput("tag", 
                  label = "Select tag:",
                  #selected = sample(tags_names, 1), # initialize the graph with a random package
                  choices = tags_names,
                  multiple = F),
      
      dateRangeInput("dates", 
                     "Date range",
                     start = "2016-01-01", 
                     end = as.character(Sys.Date())),
      
      # radioButtons("transformation", 
      #              "Data Transformation:",
      #              c("Monthly"="monthly","Yearly" ="yearly", "Qtrly" = "qtrly"))
      downloadButton("saver","Download")
    ),
    mainPanel(plotOutput("downloadsPlot"))
  )
))
