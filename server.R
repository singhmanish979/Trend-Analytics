pkgs<- c("shiny","httr","jsonlite","stringr","dplyr","ggplot2","lubridate","cranlogs","zoo","scales")
install.packages(pkgs)
lapply(pkgs,require,character.only=T)

get_initial_release_date = function(packages)
{
    min_date = Sys.Date() - 1
    
    for (pkg in packages)
    {
        # api data for package. we want the initial release - the first element of the "timeline"
        pkg_data = httr::GET(paste0("http://crandb.r-pkg.org/", pkg, "/all"))
        pkg_data = httr::content(pkg_data)
        
        initial_release = pkg_data$timeline[[1]]
        min_date = min(min_date, as.Date(initial_release))    
    }
    
    min_date
}

shinyServer(function(input, output) {
  downloads <- reactive({
      packages <- input$package
      cran_downloads0 <- failwith(NULL, cran_downloads, quiet = TRUE)
      cran_downloads0(package = packages, 
                      from    = get_initial_release_date(packages), 
                      to      = Sys.Date()-1)
  })
    
  output$downloadsPlot <- renderPlot({
      d <- downloads()
      if (input$transformation=="weekly") {
          d$count=rollapply(d$count, 7, sum, fill=NA)
      } else if (input$transformation=="cumulative") {
          d = d %>%
                group_by(package) %>%
                transmute(count=cumsum(count), date=date) 
      }

      ggplot(d, aes(date, count, color = package)) + geom_line() +
          xlab("Date") +
          scale_y_continuous(name="Number of downloads", labels = comma)
  })
  
  output$topdownloadsPlot<- renderPlot({
    ggplot(cran_top_downloads(count=50), aes(x=reorder(package,count,desc), y=count)) +
      geom_segment(aes(xend=package), yend=0, colour="grey50")+
      geom_point(size=3) + # Use a larger dot
      theme_bw() +
      theme(axis.text.x = element_text(angle=75, hjust=1,colour = 'black',size=12),
            panel.grid.major.y = element_blank())+
      xlab("CRAN R Top Download Package")+
      ylab("Number of Downloads")
    
  })

})
