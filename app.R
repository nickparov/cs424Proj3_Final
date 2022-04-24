#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

library(shinydashboard)
library(shinyWidgets)
library(data.table)
library(lubridate)
library(ggplot2)
library(leaflet)
library(dplyr)
library(rgdal)
library(shiny)
library(DT)

# ======================= READ DATA =======================
# allData <- read.csv(file = 'hourDayMonthRidesToFromTable_table.csv')

temp <- list.files(path = "./splitted_files/", pattern="*.csv", full.name = T)
allData <- plyr::ldply(temp, read.csv)
dailyData <- read.csv(file = 'eachDayTotalRides_table.csv')
hourlyData <- read.csv(file = 'eachHourTotalRides_table.csv')
milesData <- read.csv(file = 'milageBinsTotalRides_table.csv')
tripData <- read.csv(file = 'tripDurationBinsTotalRides_table.csv')
percentData <- read.csv(file = 'ridesPercentageTable_table.csv')
perTable <- read.csv(file = 'ridesPerTable.csv')
tripAreaData <- read.csv(file = 'tripDurationBinsEachAreaTotalRides_table.csv')
milesAreaData <- read.csv(file = 'milageBinsEachAreaTotalRides_table.csv')

# read in shapefile of chicago
chicago = readOGR(dsn = "./communities", layer = "geo_export_c299cc79-b126-4721-8a30-e6452f36cb8b")

bins <- c(0, 200, 1000, 10000, 100000, 300000, 500000, 1000000, Inf)
pal <- colorBin("YlOrRd", domain = percentData$total_area_rides, bins = bins)
labels <- sprintf(
  "<strong>%s</strong><br/>%g rides",
  percentData$area_name, percentData$total_area_rides
) %>% lapply(htmltools::HTML)

# ======================= MODIFY DATA =======================
# Make correctly fomatted dates
dailyData$newDate = as_date(ymd(dailyData$date))
allData$newDate = as_date(ymd(allData$date))

# ======================= MENU OPTIONS =======================

# Add the list of Chicago areas and sort it
chicagoAreas <- c("Rogers Park","West Ridge","Uptown","Lincoln Square","North Center","Lake View","Lincoln Park","Near North Side",
                  "Edison Park","Norwood Park","Jefferson Park","Forest Glen","North Park","Albany Park","Portage Park","Irving Park",
                  "Dunning","Montclare","Belmont Cragin","Hermosa","Avondale","Logan Square","Humboldt Park","West Town","Austin",
                  "West Garfield Park","East Garfield Park","Near West Side","North Lawndale","South Lawndale","Lower West Side","The Loop",
                  "Near South Side","Armour Square","Douglas","Oakland","Fuller Park","Grand Boulevard","Kenwood","Washington Park",
                  "Hyde Park","Woodlawn","South Shore","Chatham","Avalon Park","South Chicago","Burnside","Calumet Heights","Roseland","Pullman",
                  "South Deering","East Side","West Pullman","Riverdale","Hegewisch","Garfield Ridge","Archer Heights","Brighton Park",
                  "McKinley Park","Bridgeport","New City","West Elsdon","Gage Park","Clearing","West Lawn","Chicago Lawn","West Englewood",
                  "Englewood","Greater Grand Crossing","Ashburn","Auburn Gresham","Beverly","Washington Heights","Mount Greenwood",
                  "Morgan Park","O'Hare","Edgewater")
chiAreaSorted<- sort(chicagoAreas)
chicagoAreasMenu <- c("City of Chicago", chiAreaSorted)
chicagoAreas <- NULL
chiAreaSorted <- NULL

# Add corrctly formatted time modes for plots
hours24 = c("00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", 
            "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", 
            "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00")

hours24 <- factor(hours24, levels= c("00:00", "01:00", "02:00", "03:00", "04:00", "05:00", "06:00", 
                                     "07:00", "08:00", "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", 
                                     "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"))

hours12 = c("12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", 
            "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", 
            "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM")

hours12 <- factor(hours12, levels= c("12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", 
                                     "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", 
                                     "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"))

# tripTimes <- c("60.0-90.0", "90.0-120.0", "120.0-150.0", "150.0-180.0", "180.0-210.0", 
#                "210.0-240.0", "240.0-270.0", "270.0-300.0", "300.0-330.0")
# 
# tripTimes <- factor(tripTimes, levels= c("60.0-90.0", "90.0-120.0", "120.0-150.0", "150.0-180.0", "180.0-210.0", 
#                                          "210.0-240.0", "240.0-270.0", "270.0-300.0", "300.0-330.0"))

months = c("January", "February", "March", "April", "May", "June", "July", 
           "August", "September", "October", "November", "December")
months <- factor(months, levels= c("January", "February", "March", "April", "May", "June", "July",
                                   "August", "September", "October", "November", "December"))


# ======================= UI =======================
ui <- dashboardPage (
  dashboardHeader(title = "CS424 Project 3"),
  dashboardSidebar(disable = FALSE, collapsed = FALSE,
                   sidebarMenu(
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("", tabName = "cheapBlankSpace", icon = NULL),
                     menuItem("Dashboard", tabName = "Dashboard", icon = icon("chart-bar"), selected = TRUE),
                     
                     # Select area
                     selectInput("areaSelect", "Select Chicago Area", chicagoAreasMenu, selected = 'City of Chicago'),
                     
                     # Select 24-h mode
                     materialSwitch(inputId = "twntyfour", label = "24 Hour scale", status = "primary", right = TRUE, value = TRUE),
                     
                     # Select km or mi
                     materialSwitch(inputId = "kmOrM", label = "Kilometers", status = "primary", right = TRUE, value = FALSE),
                     
                     # Which data to show
                     radioGroupButtons(inputId = "totToFrom", label = "Which rides to display", direction = "vertical",
                                       choices = c("Total", "From", "To"), justified = TRUE, selected = 'Total',
                                       individual = TRUE, checkIcon = list(yes = icon("ok", lib = "glyphicon"))),
                     # About tab
                     menuItem("About Page", tabName = "About", icon = icon("info")))
  ),
  dashboardBody(
    # Add styles
    tags$style(HTML("
                    .skin-blue .main-header .navbar {
                        background-color: aliceblue;
                    }
                    .skin-blue .main-header .logo {
                        background-color: #161741;
                    }
                    .skin-blue .main-header .logo:hover {
                        background-color: #161760;
                    }
                    .skin-blue .left-side, .skin-blue .main-sidebar, .skin-blue .wrapper {
                        background-color: #161741;
                    }
                    .skin-blue .sidebar-menu>li.active>a, .skin-blue .sidebar-menu>li:hover>a {
                        color: #fff;
                        background: #161760;
                        border-left-color: #A1DDC0;
                    }
                    .skin-blue .main-header .navbar .sidebar-toggle {
                        display: none;
                    }
                    .content {
                        background-color: aliceblue;
                    }
                    body {
                        font-family: system-ui, sans-serif;
                    }
                    .h1, .h2, .h3, .h4, .h5, .h6, h1, h2, h3, h4, h5, h6 {
                        font-family: system-ui, sans-serif;
                    }
                   
                    ")),
    tabItems(
      tabItem(
        tabName = "About",
        h1("About Project Page"),
        h2("Project Name"),
        h4("Big Yellow Taxi"),
        p("Project link: https://sf8nhp-malika-yelyubayeva.shinyapps.io/cs424p3/ "),
        p("GitHub link: https://github.com/nickparov/cs424Proj3_Final"),
        p("(ADD TO GITHUB any instructions necessary to run the app. These instructions should start from the assumption that the reader has a web browser on their computer and tells the user everything else he/she needs to know and do to get it running using R-studio, including installing correct versions of all the required software)"),
        h2("Project Description"),
        p("This project is concentrated on using R to visualize data from taxi journeys in Chicago, as well as utilizing Shiny to provide users with an interactive interface for creating those visualizations. The data can be helpful for people who want to analyze the dynamics of the Chicago area - from which areas people usually come or go. "),
        p("How to use the dashboard"),
        p("Go to this link to open the dashboard: https://sf8nhp-malika-yelyubayeva.shinyapps.io/cs424p3/ "),
        p("When the dashboard loads, you will see the dashboard menu on the left and all data visualization on the right side of the screen. By default, you will be in the Dashboard tab."),
        p("From the menu, you will be able to choose the Chicago Area you want to see, 24-hour or 12-hour scale, kilometers or miles and which rides to display on the map."),
        p("Chicago Area dropdown: By default, ‘City of Chicago’ option is used. This option shows total rides in the whole city of Chicago on graphs and maps. The areas are placed in alphabetical order. By choosing a certain area, all bar charts and tables will change to data about only the selected area."),
        p("24-hour or 12-hour scale: By default, the bar chart and table about “Number of rides by hour of day (based on start time)” are showing you 24-hour scale, if you are not comfortable with it, you can see it in 12-hour scale (AM/PM) by clicking on the switch. If it is on, then the 24-hour scale is on, if off then otherwise. "),
        p(""),
        p("Kilometers or miles metrics: By default, the dashboard shows you data in Miles in the ‘Number of rides by binned distance (mi/km)’ bar chart and table. If you want to see distance in kilometers, by clicking on the switch next to “kilometers” the dashboard will convert miles to kilometers for you on both graph and table."),
        p("Which rides to display: has three options “Total”, “From” and “To”. By default, the map will show you total trips on the map with a lower number of rides colored in yellow, and a higher number of rides colored in red. By clicking on “From” the map will display the number of rides From the areas, and by clicking on “To” the map will display the number of rides To the areas."),
        h2("Data visualizations:"),
        p("	There are seven graphs and all of them have corresponding tables. Each graph and table has a title so it is easy to understand what it shows."),
        p("	The map is displayed on the right side of the dashboard. It displays all community areas of Chicago. By hovering on one of them it will highlight the area's borders and show the popup as the number of rides. If you click on a certain community area, then it will automatically be shown on the bar charts and tables."),
        p(""),
        p("1+ page worth of text on the data you used, including where you got it, what manipulations you did to it. This should be detailed enough to allow any reasonably computer literate person to reproduce what you did "),
        h2("Versions"),
        p("R version 4.1.2 (2021-11-01) -- 'Bird Hippie' https://repo.miserver.it.umich.edu/cran/ "),
        p("RStudio (2021.09.2) -- 'Ghost Orchid' https://www.rstudio.com/products/rstudio/ "),
        p("Shiny version ‘1.7.1’"),
        h2("Downloads"),
        p("How to download R: https://www.r-project.org "),
        p("How to download RStudio: https://www.rstudio.com/products/rstudio/download/ "),
        p("How to setup Shiny App: https://shiny.rstudio.com/articles/build.html "),
        p("Download data for this project (csv format): https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy  "),
        p("Download boundaries of Chicago Community Areas: https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6 "),
        h2("Install libraries"),
        p("Run these commands in your RStudio console to install the packages:"),
        p("install.packages(‘shinydashboard’)"),
        p("install.packages(‘shinyWidgets’)"),
        p("install.packages(‘data.table’)"),
        p("install.packages(‘lubridate’)"),
        p("install.packages(‘ggplot2’)"),
        p("install.packages(‘leaflet’)"),
        p("install.packages(‘rgdal’)"),
        p("install.packages(‘shiny’)"),
        p("install.packages(‘DT’)"),
        h2("Data"),
        p("The original data can be found on the Chicago Data Portal. The 2019 statistics can be found here: https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy  "),
        p("The data is 7 GB in size and comprises 16.5 million rows. Because of the pre-COVID time of Chicago Taxi transportation, data was only gathered from the 2019 year to depict an 'average' year."),
        h4("How to process data"),
        p("Main Overview Of How We processed Data:"),
        p("We used our own approach as of how to filter out and process all the data that we have. We have developed a nodejs program to handle all the filtering part as well as parts of R code to do the minor required alterations to the data. "),
        p("In this part of the document I will describe the main algorithm that we used to filter out data, process it and export to csv table ready to be used in the application."),
        h4("Nodejs Program Main Algorithm code:"),
        p("const fs = require('fs');"),
        p("const nReadlines = require('n-readlines');"),
        p("const broadbandLines = new nReadlines('data.csv');"),
        p("// line by line"),
        p("while ((line = broadbandLines.next())) {"),
        p("   // parse to ASCII"),
        p("   const lineStr = line.toString('ascii');"),
        p("   // if first line -> get columns array"),
        p("   lineNumber === 1 &&"),
        p("       columns.push(...lineStr.split(',')) &&"),
        p("       setNeededColumns(lineStr.split(',')) &&"),
        p("       wstream.write(arrayToCsvLine(neededColumns));"),
        p("   // get values arr"),
        p("   const values = lineStr.split(',');"),
        p("   // get data object"),
        p("   const data = arrsToObj(columns, values); "),
        p("   // check if data is correct"),
        p("   if (correctData(data)) {"),
        p("       // get needed part from curr data"),
        p("       const dataArr = getNeededDataArr(data);"),
        p("	// process each row that we read"),
        p("       Manipulator.process(getNeededDataObj(data));"),
        p("	// increment the number of elements"),
        p("       trueElsNum++;"),
        p("       // save to csv"),
        p("       wstream.write(arrayToCsvLine(dataArr));"),
        p("       // show mem"),
        p("       if (trueElsNum % 250000 === 0) showMemory();"),
        p("   }"),
        p("   lineNumber++;"),
        p("}"),
        p(""),
        p("Manipulator.exportAllTables();"),
        p(""),
        h4("Basically, it consists of the main following steps: "),
        p("Reading a file line by line, "),
        p("Parsing that line into data object, "),
        p("Filtering & processing that object, "),
        p("Saving that filtered object into new csv data file, "),
        p("Exporting all generated tables data into csv files. "),
        p("Let’s delve a bit deeper into these steps:"),
        h4("Reading a file line by line:"),
        p("We are reading the whole 7Gb data file line by line by using a simple library package “n-readlines” that you can install by running “npm i n-readlines” and then the following:"),
        p("while ((line = broadbandLines.next())) will parse each line in the buffer which we then parsed by using “line.toString('ascii');” into ascii format, which is a regular string."),
        h4("Parsing that line into data object:"),
        p("After we obtained string representation of buffer that was read, we parse that line into an data object to be able to manipulate it inside NodeJS. To do that, we have created two functions that take care of that: getNeededDataArr, getNeededDataObj."),
        p("First function returns the data values in form of array, whereas the second function returns the object with the following structure: {date, duration, miles, from_area, to_area, company, year, month, day, hour, minute}."),
        p("Filtering & processing that object:"),
        p("Filtering is done by comparing the data object through multiple conditions in if statement like so:"),
        p(" "),
        p("if ( parseFloat(row['Trip Miles']) >= 0.5 &&"),
        p("     parseFloat(row['Trip Miles']) <= 100 &&"),
        p("     parseInt(row['Trip Seconds']) <= 18000 &&"),
        p("     parseInt(row['Trip Seconds']) >= 60 &&"),
        p("     row['Pickup Community Area'] != false &&"),
        p("     row['Dropoff Community Area'] != false"),
        p("  ) {"),
        p("	return true;"),
        p("   } else {"),
        p("	return false;"),
        p("}"),
        p(""),
        p("This if statement directly relates to the requirements stated on the project 3 website on which data to filter out. "),
        p(""),
        h4("Processing is a complicated process which results in generating all the needed tables in csv format."),
        p("Those include: eachDayTotalRides_table, eachHourTotalRides_table, hourDayMonthRidesToFromTable_table and all the other tables that we used to lower the use of cpu and memory for our project. "),
        p("By pre-generating these csv tables we are able to achieve a great performance and memory usage which results in fast page loading time and fast update of the elements in our visualization."),
        p("Processing takes place on this line:"),
        p("“Manipulator.process(getNeededDataObj(data));”"),
        p("What it does is just passing our data object that we got from the previous step to the main Manipulator that is responsible for all the pre-generation of csv files for the project. "),
        p("In a nutshell, when we pass a data object to Manipulator, it looks which tables need to be appended with this object and specifically which information to append to them, and save all these information in a matrix format for each table for the future csv export."),
        h4("Saving that filtered object into new csv data file:"),
        p("When we filter out the needed data object and process it, we append it to the new csv file designated to hold all filtered elements."),
        h4("Exporting all generated tables data into csv files:"),
        p("After we have filtered & processed all the data objects parsed from the main data file, we export pre-generated tables data into csv formatted tables. To achieve this, we firstly export columns as a first line in new csv file and then, we iterate through each data piece that we calculated and append it to file as a parsed csv line. "),
        h2("How to install & use this parser NodeJS Program?"),
        p("First of all, make sure you have NodeJS installed in your system."),
        p("https://nodejs.org/en/download/"),
        p("Then, In order to install this program you should first download the source code from github: https://github.com/nickparov/cs424_project3_ParserFilter"),
        p("Next, download original dataset file from chicago portal:"),
        p("https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy"),
        p("And place 7GB data downloaded file into the folder of the program that you downloaded in the previous step. Then, rename it as “data.csv”."),
        p("After that: open your program folder and run following commands to install all needed dependencies: “npm install”."),
        p("Then, run “node main.js” which will take about 3-5mins depending on your machine. This command will produce all the needed csv files for the application to run which you will find in “csv” folder after program finishes execution as well as “csv-HDMR_TO_FROM” folder which is going to have smaller set of files generated for hourDayMonthRidesToFrom Table which we use in our application. "),
        p("	"),
        p(""),
        p(""),
        p(""),
        h2("How to convert miles to kilometers:"),
        p("	Open csv file ‘milageBinsTotalRides_table.csv’ in Excel."),
        p("	In the new column, use function “=CONVERT(A2,'km','mi')” "),
        p("	Instead of A2, paste the first cell with miles data."),
        p("	Drag down the converted cell and all miles are converted to kilometers."),
        p(""),
        h2("How to convert 24-hour time to 12-hour:"),
        p("	Open csv file ‘eachHourTotalRides_table.csv’ in Excel."),
        p("	In the new column, on the same row as “00” write 12."),
        p("	In the same column, under 12, write 1 and drag down till the next 12 occurring."),
        p("	Check whether data is correlated to each other in the way that 00 and 12, 13 and 1, 23 and 11 are in the same rows."),
        p("	In the new column on the right write “AM” and drag down till 11. Next to the 12, write “PM” and drag down the cell till the end."),
        p("	Check whether data is mapped correctly."),
        p("	Name new columns as ‘hour_tw’ and ‘ampm’."),
        p("	Save the new modified file or replace the old one."),
        p(""),
        h2("Interesting Facts:"),
        p("One of the interesting things we found is that in general, the number of people going out and in the area is the same. This could be due to the fact that a lot of people take taxis to go somewhere and come back home, so the average number of rides to/from areas is around 50% for all Chicago community areas."),
        p("Another thing is that the most ‘rideable’ areas were ‘The north side’, ‘the loop’ and ‘new west side’. These areas have the most number of all types of rides in 2019. We figured out that this might be because of the number of people living in that area. The population of ‘Near North Side’ is equal to 89,995 from 2018 data. While its neighboring area ‘Jefferson park’ has the population of 27,989 from 2018 data."),
        p("The mileage of all trips is mostly around 0.4-0.6 miles and it decreases as the distance grows. The cause of this might be the taxi prices, since they usually charge for miles, so people get taxis to get around short distances. While the most popular duration time is about 4 to 5 minutes. "),
        p("Interestingly, that the most number of rides happened in March. This might be due to the Spring break and students going out more, or because March usually has good weather after a long winter and people in general want to go out more."),
        p("Most rides happen during weekdays, and there are much less rides on weekends."),
        p("Less rides happen at 5AM, and most of the rides happen during lunch time, peaking at 1PM."),
        p(""),
        
      ),
      
      tabItem(
        tags$style(HTML("
                    .box.box-solid.box-primary>.box-header {
                          color: #fff;
                          background: #23355B;
                          background-color: #23355B;
                          border-top-right-radius: 15px;
                          border-top-left-radius: 15px;
                    }
                    .box.box-solid.box-primary {
                        border: 0px;
                        border-radius: 15px;
                    }")),
        style = "font-size: 10px;",
        tabName = "Dashboard",
        fluidRow(
          column(9,
                 column(6,
                        fluidRow(
                          box(
                            title = "Percentage of rides going to / from Chicago Community Areas",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("totalRidesBar", height = 200)
                          )
                        ),
                        fluidRow(
                          column(4, box(
                            title = "Number of rides by day",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("dayTable", height = 200)
                          )),
                          column(8, box(
                            title = "Number of rides by day",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("dayBar", height = 200)
                          ))
                        ),
                        fluidRow(
                          column(4, box(
                            title = "Number of rides by hour of day (based on start time)",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("hourTable", height = 200)
                          )),
                          column(8, box(
                            title = "Number of rides by hour of day (based on start time)",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("hourBar", height = 200)
                          ))
                        ),
                        fluidRow(
                          column(4, box(
                            title = "Number of rides by day of week",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("weekTable", height = 200)
                          )),
                          column(8, box(
                            title = "Number of rides by day of week",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("weekBar", height = 200)
                            
                          ))
                        ),
                        fluidRow(
                          column(4, box(
                            title = "Number of rides by month",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("monthTable", height = 200)
                          )),
                          column(8, box(
                            title = "Number of rides by month",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("monthBar", height = 200)
                          ))
                        ),
                 ),
                 column(6,
                        fluidRow(
                          box(
                            title = "Percentage of rides going to / from Chicago Community Areas",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("totalRidesTable", height = 200)
                          )
                        ),
                        fluidRow(
                          column(8, box(
                            title = "Number of rides by binned distance (mi/km)",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("mileageBar", height = 400)
                          )),
                          column(4, box(
                            title = "Number of rides by binned distance (mi/km)",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("mialageTable", height = 400)
                          ))
                        ),
                        fluidRow(
                          column(8, box(
                            title = "Number of rides by binned trip time",
                            solidHeader = TRUE, status = "primary", width = 12,
                            plotOutput("tripBar", height = 400)
                          )),
                          column(4, box(
                            title = "Number of rides by binned trip time",
                            solidHeader = TRUE, status = "primary", width = 12,
                            dataTableOutput("tripTable", height = 400)
                          ))
                        )
                 )
          ),
          column(3, box(
            title = "Chicago Community Areas Map", 
            solidHeader = TRUE, status = "primary", width = 12,
            leafletOutput("map", height = 1380),
            absolutePanel(bottom = 30, left = 10)
          ))
        ) # end of fluid row
      )
    )
  )
)

# ======================= SERVER =======================
server <- function(input, output, session) {
  # Reactive functions
  justOneAreaReactive <- reactive({subset(allData, allData$area_name == input$areaSelect)})
  justOneAreaPercentReactive <- reactive({subset(percentData, percentData$area_name == input$areaSelect)})
  justOneAreaTripReactive <- reactive({subset(tripAreaData, tripAreaData$area_name == input$areaSelect)})
  justOneAreaMilesReactive <- reactive({subset(milesAreaData, milesAreaData$area_name == input$areaSelect)})
  
  # ================ PERCENTAGE BY AREA ================
  output$totalRidesBar <- renderPlot({
    # Display total
    if (input$areaSelect == 'City of Chicago') {
      ggplot(percentData, aes(y = fromto, x = area_name, fill = identifier)) +
        geom_bar(position="fill", stat = "identity") +
        labs(x = "Chicago Community Areas", y = "Percent (%)") +
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic")) +
        theme(axis.text.x = element_text(angle = 90, hjust=1)) +
        scale_fill_manual(values = c("#F4E75E", "#A1DDC0"))
    } else {
      # Display certain area
      justOneArea <- justOneAreaPercentReactive()
      ggplot(justOneArea, aes(y = area_name, x = fromto, fill = identifier)) +
        geom_bar(position="fill", stat = "identity") +
        labs(x = 'Percent (%)', y = ' ') +
        theme_minimal() +
        scale_fill_manual(values = c("#F4E75E", "#A1DDC0"))
    }
  })
  
  output$totalRidesTable <- DT::renderDataTable({
    if (input$areaSelect == 'City of Chicago') {
      # Display total
      datatable(perTable,
                colnames = c('Area name', 'Area code', 'Rides From (%)', 'Rides To (%)'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    } else {
      # Display certain area
      justOneArea <- justOneAreaPercentReactive()
      datatable(justOneArea[c('area_name', 'area_code', 'from_share', 'to_share')],
                colnames = c('Area name', 'Area code', 'Rides From (%)', 'Rides To (%)'),
                options = list(pageLength = 1, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    }
  })
  
  # ======================= DAY =======================
  
  output$dayBar <- renderPlot({
    if (input$areaSelect == 'City of Chicago') {
      # Display total
      ggplot(dailyData, aes(x = newDate, y = rides)) +
        geom_bar(stat = "identity", fill = "#F4E75E") +
        labs(x = "Total daily rides", y = "Rides") +
        scale_x_date(date_labels="%d %b",date_breaks  ="1 day") +
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic")) +
        theme(axis.text.x = element_text(angle = 90, hjust=1))
    } else {
      # Display certain area
      justOneArea <- justOneAreaReactive()
      daily_sums <- aggregate(x = justOneArea$total, by = list(date(justOneArea$newDate)), FUN = sum)
      ggplot(daily_sums, aes(x = Group.1, y = x)) +
        geom_bar(stat = "identity", fill = "#F4E75E") +
        labs(x = "Total daily rides", y = "Rides") +
        scale_x_date(date_labels="%d %b",date_breaks  ="1 day") +
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic")) +
        theme(axis.text.x = element_text(angle = 90, hjust=1))
    }
  })
  
  output$dayTable <- DT::renderDataTable({
    if (input$areaSelect == 'City of Chicago') {
      # Display total
      datatable(dailyData[0:2],
                colnames = c('Month and day', 'Rides'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    } else {
      # Display certain area
      justOneArea <- justOneAreaReactive()
      daily_sums <- aggregate(x = justOneArea$total, by = list(date(justOneArea$newDate)), FUN = sum)
      datatable(daily_sums,
                colnames = c('Date', 'Rides'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    }
  })
  
  # ======================= HOUR =======================
  
  output$hourBar <- renderPlot({
    if (input$twntyfour == TRUE) {
      # if 24h selected
      if (input$areaSelect == 'City of Chicago') {
        # Display total
        ggplot(hourlyData, aes(x=hours24, y=rides)) +
          geom_bar(stat="identity", fill="#F4E75E") +
          labs(x="Total rides by hours of the day (24 hour)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic"))
      } else {
        # Display certain area
        justOneArea <- justOneAreaReactive()
        ggplot(justOneArea, aes(x=factor(hour), y=total)) +
          geom_bar(stat="identity", fill="#F4E75E") +
          labs(x="Total rides by hours of the day (24 hour)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic"))
      } 
    } else if (input$twntyfour == FALSE) {
      # if 12 h selected
      if (input$areaSelect == 'City of Chicago') {
        # Display total
        ggplot(hourlyData, aes(x=hours12, y=rides)) +
          geom_bar(stat="identity", fill="#F4E75E") +
          labs(x="Total rides by hours of the day (12 hour)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic"))
      } else {
        # Display certain area
        justOneArea <- justOneAreaReactive()
        hourly_sums <- aggregate(x = justOneArea$total, by = list(justOneArea$hour12), FUN = sum)
        
        ggplot(hourly_sums, aes(x=hours12, y=x)) +
          geom_bar(stat="identity", fill="#F4E75E") +
          labs(x="Total rides by hours of the day (12 hour)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic"))
      }
    } 
  })
  
  output$hourTable <- DT::renderDataTable({
    if (input$twntyfour == TRUE) {
      # if 24h selected
      if (input$areaSelect == 'City of Chicago') {
        # Disaply total
        datatable(hourlyData[c('hour', 'rides')],
                  colnames = c('Hour', 'Rides'),
                  options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
      } else {
        # Display certain area
        justOneArea <- justOneAreaReactive()
        datatable(justOneArea[c('hour', 'total')],
                  colnames = c('Hour', 'Rides'),
                  options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
        
      }
    } else if (input$twntyfour == FALSE) {
      # if 12h selected
      if (input$areaSelect == 'City of Chicago') {
        #display totals
        datatable(hourlyData[c('hour12', 'rides')],
                  colnames = c('Hour', 'Rides'),
                  options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
      } else {
        # Display certain area
        justOneArea <- justOneAreaReactive()
        datatable(justOneArea[c('hour12', 'total')],
                  colnames = c('Hour', 'Rides'),
                  options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
        
        
      }
    }
    
  })
  
  # ======================= DAY OF WEEK =======================
  
  output$weekBar <- renderPlot({
    # Display total
    if (input$areaSelect == 'City of Chicago') {
      weekly_sums <- aggregate(x = dailyData$rides, by = list(weekdays(as.Date(dailyData$newDate))), FUN = sum)
      weekly_sums$Group.1 <- factor(weekly_sums$Group.1, levels= c("Monday", "Tuesday", 
                                                                   "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
      ggplot(weekly_sums, aes(x=Group.1, y=x)) +
        geom_bar(stat="identity", fill="#F4E75E") +
        labs(x=" ", y = "Rides")+
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic"))
    } else {
      # Display certain area
      justOneArea <- justOneAreaReactive()
      weekly_sums <- aggregate(x = justOneArea$total, by = list(weekdays(as.Date(justOneArea$newDate))), FUN = sum)
      weekly_sums$Group.1 <- factor(weekly_sums$Group.1, levels= c("Monday", "Tuesday", 
                                                                   "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
      ggplot(weekly_sums, aes(x=Group.1, y=x)) +
        geom_bar(stat="identity", fill="#F4E75E") +
        labs(x=" ", y = "Rides")+
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic"))
    }
  })
  
  output$weekTable <- DT::renderDataTable({
    # Display total
    if (input$areaSelect == 'City of Chicago') {
      weekly_sums <- aggregate(x = dailyData$rides, by = list(weekdays(as.Date(dailyData$newDate))), FUN = sum)
      datatable(weekly_sums,
                colnames = c('Day of the week', 'Rides'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    } else {
      # Display certain area
      justOneArea <- justOneAreaReactive()
      weekly_sums <- aggregate(x = justOneArea$total, by = list(weekdays(as.Date(justOneArea$newDate))), FUN = sum)
      datatable(weekly_sums,
                colnames = c('Day of the week', 'Rides'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    }
  })
  
  # ======================= MONTH =======================
  
  output$monthBar <- renderPlot({
    # Display total
    if (input$areaSelect == 'City of Chicago') {
      monthly_sums <- aggregate(x = dailyData$rides, by = list(dailyData$month), FUN = sum)
      ggplot(monthly_sums, aes(x = months, y = x)) +
        geom_bar(stat = "identity", fill = "#F4E75E") +
        labs(x = " ", y = "Rides") +
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic"))
    } else {
      # Display certain area
      justOneArea <- justOneAreaReactive()
      monthly_sums <- aggregate(x = justOneArea$total, by = list(month(justOneArea$newDate)), FUN = sum)
      monthly_sums$Months <- months
      ggplot(monthly_sums, aes(x=Months, y=x)) +
        geom_bar(stat="identity", fill="#F4E75E") +
        labs(x=" ", y = "Rides")+
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic"))
    }
  })
  
  output$monthTable <- DT::renderDataTable({
    # Display total
    if (input$areaSelect == 'City of Chicago') {
      monthly_sums <- aggregate(x = dailyData$rides, by = list(dailyData$month), FUN = sum)
      monthly_sums$Months <- months
      datatable(monthly_sums[c('Months', 'x')],
                colnames = c('Month', 'Rides'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    } else {
      # Display certain area
      justOneArea <- justOneAreaReactive()
      monthly_sums <- aggregate(x = justOneArea$total, by = list(month(justOneArea$newDate)), FUN = sum)
      monthly_sums$Months <- months
      datatable(monthly_sums[c('Months', 'x')],
                colnames = c('Month', 'Rides'),
                options = list(pageLength = 4, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
      
    }
  })
  
  # ======================= BINNED MILEAGE / KM =======================
  
  output$mileageBar <- renderPlot({
    if (input$kmOrM == FALSE) {
      # if miles selected
      if (input$areaSelect == 'City of Chicago') {
        # Display total
        ggplot(milesData[1:2], aes(x=milage, y=rides)) +
          geom_bar(stat="identity", fill="#A1DDC0") +
          labs(x="Trip distance (mi)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic")) +
          theme(axis.text.x = element_text(angle = 90, hjust=1))
        
      } else {
        # Display certain area
        justOneArea <- justOneAreaMilesReactive()
        ggplot(justOneArea, aes(x=miles, y=rides)) +
          geom_bar(stat="identity", fill="#A1DDC0") +
          labs(x="Trip distance (mi)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic")) +
          theme(axis.text.x = element_text(angle = 90, hjust=1))
        
      }
    } else if (input$kmOrM == TRUE) {
      # if km selected
      if (input$areaSelect == 'City of Chicago') {
        # Display total
        ggplot(milesData[c('km', 'rides')], aes(x=km, y=rides)) +
          geom_bar(stat="identity", fill="#A1DDC0") +
          labs(x="Trip distance (km)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic")) +
          theme(axis.text.x = element_text(angle = 90, hjust=1))
        
      } else {
        # Display certain area
        justOneArea <- justOneAreaMilesReactive()
        ggplot(justOneArea, aes(x=km, y=rides)) +
          geom_bar(stat="identity", fill="#A1DDC0") +
          labs(x="Trip distance (km)", y = "Rides")+
          theme_minimal() +
          theme(axis.title.y = element_text(face = "italic")) +
          theme(axis.text.x = element_text(angle = 90, hjust=1))
      }
    }
    
    
  })
  
  output$mialageTable <- DT::renderDataTable({
    if (input$kmOrM == FALSE) {
      # if miles selected
      if (input$areaSelect == 'City of Chicago') {
        # Display total
        datatable(milesData[c('milage', 'rides')],
                  colnames = c('Trip distance (mi)', 'Rides'),
                  options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
      } else {
        # Display certain area
        justOneArea <- justOneAreaMilesReactive()
        datatable(justOneArea[c('miles', 'rides')],
                  colnames = c('Trip distance (mi)', 'Rides'),
                  options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
        
      }
    } else if (input$kmOrM == TRUE) {
      # if km selected
      if (input$areaSelect == 'City of Chicago') {
        # Display total
        datatable(milesData[c('km', 'rides')],
                  colnames = c('Trip distance (km)', 'Rides'),
                  options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
      } else {
        # Display certain area
        justOneArea <- justOneAreaMilesReactive()
        datatable(justOneArea[c('km', 'rides')],
                  colnames = c('Trip distance (km)', 'Rides'),
                  options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
                  rownames = FALSE
        )
        
      }
    }
  })
  
  # ======================= BINNED TRIP TIME =======================
  
  output$tripBar <- renderPlot({
    if (input$areaSelect == 'City of Chicago') { 
      # Display total
      ggplot(tripData, aes(x=trip_duration, y=rides)) +
        geom_bar(stat="identity", fill="#A1DDC0") +
        labs(x="Trip duration (30 minutes)", y = "Rides")+
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic"))+
        theme(axis.text.x = element_text(angle = 90, hjust=1))
      
    } else {
      # Display certain area
      justOneArea <- justOneAreaTripReactive()
      ggplot(justOneArea, aes(x=time, y=rides)) +
        geom_bar(stat="identity", fill="#A1DDC0") +
        labs(x="Trip duration (30 minutes)", y = "Rides")+
        theme_minimal() +
        theme(axis.title.y = element_text(face = "italic"))+
        theme(axis.text.x = element_text(angle = 90, hjust=1))
      
    }
  })
  
  output$tripTable <- DT::renderDataTable({
    if (input$areaSelect == 'City of Chicago') {
      # Display total
      datatable(tripData[c('trip_duration', 'rides')],
                colnames = c('Trip duration (30 minutes)', 'Rides'),
                options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    } else {
      # Display certain area
      justOneArea <- justOneAreaTripReactive()
      datatable(justOneArea[c('time', 'rides')],
                colnames = c('Trip duration (30 minutes)', 'Rides'),
                options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
                rownames = FALSE
      )
    }
  })
  
  # ======================= MAP =======================
  output$map <- renderLeaflet({
    # Display Total rides
    if (input$totToFrom == 'Total') {
      leaflet(chicago) %>%
        setView(lng = -87.71584484354437, lat = 41.812210623101755 , zoom = 10.5) %>%
        addProviderTiles("MapBox", options = providerTileOptions(id = "mapbox.light")) %>% 
        addPolygons()  %>% 
        addPolygons(fillColor = ~pal(percentData$total_area_rides),weight = 2,opacity = 1,color = "white",dashArray = "3",fillOpacity = 0.7, layerId = percentData$area_name,
                    highlightOptions = highlightOptions(weight = 5,color = "#fff",dashArray = "",fillOpacity = 0.7,bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),textsize = "15px",direction = "auto")) %>% 
        addLegend(pal = pal, values = ~percentData$total_area_rides, opacity = 0.7, title = NULL, position = "bottomright")
      
    } else if (input$totToFrom == 'To') {
      # Display To rides
      leaflet(chicago) %>%
        setView(lng = -87.71584484354437, lat = 41.812210623101755 , zoom = 10.5) %>%
        addProviderTiles("MapBox", options = providerTileOptions(id = "mapbox.light")) %>%
        addPolygons()  %>%
        addPolygons(fillColor = ~pal(percentData$to),weight = 2,opacity = 1,color = "white",dashArray = "3",fillOpacity = 0.7, layerId = percentData$area_name,
                    highlightOptions = highlightOptions(weight = 5,color = "#fff",dashArray = "",fillOpacity = 0.7,bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),textsize = "15px",direction = "auto")) %>%
        addLegend(pal = pal, values = ~percentData$total_area_rides, opacity = 0.7, title = NULL, position = "bottomright")
      
    } else if (input$totToFrom == 'From') {
      # Display From rides
      leaflet(chicago) %>%
        setView(lng = -87.71584484354437, lat = 41.812210623101755 , zoom = 10.5) %>%
        addProviderTiles("MapBox", options = providerTileOptions(id = "mapbox.light")) %>%
        addPolygons()  %>%
        addPolygons(fillColor = ~pal(percentData$from),weight = 2,opacity = 1,color = "white",dashArray = "3",fillOpacity = 0.7, layerId = percentData$area_name,
                    highlightOptions = highlightOptions(weight = 5,color = "#fff",dashArray = "",fillOpacity = 0.7,bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"),textsize = "15px",direction = "auto")) %>%
        addLegend(pal = pal, values = ~percentData$total_area_rides, opacity = 0.7, title = NULL, position = "bottomright")
    }
    
  })
  
  # Check for which area was clicked
  observeEvent({input$map_click }, {
    print(input$map_shape_click$id)
    updateSelectizeInput(session, 'areaSelect', choices = chicagoAreasMenu, server = TRUE, selected=input$map_shape_click$id)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
