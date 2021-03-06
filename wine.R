library(shiny)
require(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
#Load the csv file
winedata1 <-read.csv("file:///C:/Users/home/Desktop/wine project/wine-reviews/winemag-data_first150k.csv")
#check variables
names(winedata1)
#eliminate column 1
winedata1[,1]=NULL
names(winedata1)

winedata2<- read.csv("file:///C:/Users/home/Desktop/wine project/wine-reviews/winemag-data-130k-v2.csv")
names(winedata2)
winedata2[,1]=NULL
names(winedata2)
winedata2[,9]=NULL
names(winedata2)
winedata2[,9]=NULL
names(winedata2)
winedata2[,9]=NULL
names(winedata2)

#load the json file
library(jsonlite)
winedata3 <- stream_in(file("file:///C:/Users/home/Desktop/wine project/wine-reviews/winemag-data-130k-v2.json"))
names(winedata3)
winedata3[,2]=NULL
names(winedata3)
winedata3[,3]=NULL
names(winedata3)
winedata3[,3]=NULL
names(winedata3)
#Reorder column
col_order <- c("country", "description", "designation",
               "points", "price","province","region_1","region_2","variety","winery")
my_data2 <- winedata3[, col_order]
names(my_data2)

#binding the files
newfile<-rbind(winedata1,winedata2,my_data2)
head(newfile)
#Check whether there is missing values
sum(is.na(newfile))
#omit the missing values
newfile<-na.omit(newfile)
sum(is.na(newfile))
class(newfile$points)
class(newfile$price)
mean(newfile$points)
mean(newfile$price)
newfile$points <- as.numeric(newfile$points) #Integer conversion
mean(newfile$points)



library(shinydashboard)
#Dashboard header carrying the title of the dashboard
header <- dashboardHeader(title = "Wine Ratings - Visualized", ###########
                          titleWidth = 275) 

#Sidebar content of the dashboard
sidebar <- dashboardSidebar(width = 400,
                            sidebarMenu(
                              
                              menuItem("Background", tabName = "background"),
                              menuItem("Best wine variety according to points and price", tabName = "ptsPrice"),
                              menuItem("Top 5 wine Producing country", tabName = "plot2")

                            )
)

## -- FIRST TAB: ######################
frow1 <- fluidRow(
  valueBoxOutput("value1")
  ,valueBoxOutput("value2")
  ,valueBoxOutput("value3")
)
frow2 <- fluidRow( 
  box(
    width = "1000px",
    title = "plot price Vs points"
    ,status = "primary"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    , plotlyOutput("plot"), height = "1000px",inline = FALSE)
  
)
t3<- tabItem(tabName = "plot2",
             fluidPage(
               box(
              
                 
                 br(),
                 plotOutput("barplot"),
                 
                 width = "1000px", height = "1000px"
                 )
             )
)
t1<- tabItem(tabName = "background",
             fluidRow(
               box(
                 
                 h2("Background", style="text-align: center;"),
                 
                 br(),
                 h4("* More than 110,000 different wines from 42 countries"),
                 h4("* Ratings ranged between 80-100 points"),
                 h4("* Wines priced at $4-$3300 per bottle"),
                 br(),
                 h4("Motivation: "),
                 h5(" - To investigate the relationship between a wine's 
                    rating and its price, origin, and varietal"),
                 br(),
                 
                 width = 12
                 )
             )
)

#end 1st tab

## -- SECOND TAB: ######################
t2<-tabItem(tabName = "ptsPrice", 
            frow1,frow2
)#end 2nd tab



# combine the fluid row to make the body
body <- dashboardBody(tabItems(t1,t2,t3))
ui <- dashboardPage(title = 'This is my Page title', header, sidebar, body, skin='red')

server <- function(input, output){
  
  topvariety_price<- newfile %>% group_by(variety)  %>% summarise(value=max(price)) %>% filter(value==max(value))
  topvariety_points<- newfile %>% group_by(variety)  %>% summarise(value=max(points)) %>% filter(value==max(value))
  output$value1 <- renderValueBox({
    valueBox(
      formatC(topvariety_price$value, format="d", big.mark=',')
      ,paste(' Top Variety:',topvariety_price$variety),
      icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })  
  p<-subset(newfile$points,  newfile$points==100)
  c<-subset(newfile$country,  newfile$points==100)
  v<-subset(newfile$variety,  newfile$points==100)
  p
  c
  v
  df<- data.frame(p,c,v)
  df
  output$barplot <- renderPlot({
    ggplot( data = df,
            aes(x= df$p, y= df$c, fill=factor(df$v))) + 
      geom_bar(position = "dodge", stat = "identity") + ylab("Country") + 
      xlab("Points") + theme(legend.position="bottom" 
                             ,plot.title = element_text(size=15, face="bold")) + 
      ggtitle("Top wine variety with producing country") + labs(fill = "variety") 
  })  
  
  output$value2 <- renderValueBox({
    valueBox(
      formatC(topvariety_points$value, format="d", big.mark=',')
      ,paste('Top Variety:',topvariety_points$variety),
      icon = icon("stats",lib='glyphicon')
      ,color = "purple")  
  })  
  Points<-subset(newfile$points,  newfile$price>=100 & newfile$price<=3300)
  Price<-subset(newfile$price,  newfile$price>=100 & newfile$price<=3300)
  varity1<-subset(newfile$variety,  newfile$price>=100 & newfile$price<=3300)
  df1<-data.frame(Points,Price,varity1)
  df1
  output$plot <- renderPlotly({
    plot_ly(df1, x = ~Price, y = ~Points, text = paste('Variety: ', df1$varity1))
  })
}
shinyApp(ui, server)

