pkgs<- c("shiny","httr","jsonlite","stringr","dplyr","ggplot2","lubridate","cranlogs","zoo","scales")
lapply(pkgs,require,character.only=T)
source("get tagged questions fn.R")

shinyServer(function(input,output){
  
  downloads <- reactive({
    packages <- input$tag
    tmp<- get.tagged.questions(tag = packages,fromdate = input$dates[1],todate = input$dates[2])
    tmp<- tmp[,c("tags","is_answered","view_count","last_activity_date","creation_date","question_id","link","title","name")]
    tmp$Months<- month(tmp$creation_date,label=T)
    tmp$Years<- year(tmp$creation_date)
    tmp$Qtrs<- quarter(tmp$creation_date)
    tmp$var<- 1
    tmp
  })

  output$downloadsPlot <- renderPlot({
    d <- downloads()
    d <- aggregate(var~creation_date+name,d,sum)
    # if (input$transformation=="monthly") {
    #   d=aggregate(var~Years+Months+name,d,sum)
    # } else if (input$transformation=="qtrly"){
    #   d=aggregate(var~Years+Qtrs+name,d,sum)
    # } else if (input$transformation=="yearly") {
    #   d = aggregate(var~Years+name,d,sum)
    # }

    ggplot(d, aes(creation_date, var, color = name)) + geom_line() +
      xlab("Date") +
      scale_y_continuous(name="Number of Question tagged", labels = comma)
  })
  
  output$saver <- downloadHandler(
    filename = function() { paste("Tag Data For Viz", '.csv', sep='') },
    content = function(file) {
      write.csv(downloads(), file,row.names = F)
    }
  )
})