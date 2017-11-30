.libPaths("./R-Portable/App/R-Portable/library")
# the path to portable chrome
browser.path = file.path(getwd(),"GoogleChromePortable/GoogleChromePortable.exe")
options(browser = browser.path)
shiny::runApp("./cran-download-stats/",port=8888,launch.browser=TRUE)