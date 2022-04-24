<p class="has-line-data" data-line-start="0" data-line-end="12">Project Name<br>
Big Yellow Taxi<br>
Project link: <a href="https://sf8nhp-malika-yelyubayeva.shinyapps.io/cs424p3/">https://sf8nhp-malika-yelyubayeva.shinyapps.io/cs424p3/</a><br>
GitHub link: <a href="https://github.com/nickparov/cs424Proj3_Final">https://github.com/nickparov/cs424Proj3_Final</a><br>
Project Description<br>
This project is concentrated on using R to visualize data from taxi journeys in Chicago, as well as utilizing Shiny to provide users with an interactive interface for creating those visualizations. The data can be helpful for people who want to analyze the dynamics of the Chicago area - from which areas people usually come or go.<br>
How to use the dashboard<br>
Go to this link to open the dashboard: <a href="https://sf8nhp-malika-yelyubayeva.shinyapps.io/cs424p3/">https://sf8nhp-malika-yelyubayeva.shinyapps.io/cs424p3/</a><br>
When the dashboard loads, you will see the dashboard menu on the left and all data visualization on the right side of the screen. By default, you will be in the Dashboard tab.<br>
From the menu, you will be able to choose the Chicago Area you want to see, 24-hour or 12-hour scale, kilometers or miles and which rides to display on the map.<br>
Chicago Area dropdown: By default, ‘City of Chicago’ option is used. This option shows total rides in the whole city of Chicago on graphs and maps. The areas are placed in alphabetical order. By choosing a certain area, all bar charts and tables will change to data about only the selected area.<br>
24-hour or 12-hour scale: By default, the bar chart and table about “Number of rides by hour of day (based on start time)” are showing you 24-hour scale, if you are not comfortable with it, you can see it in 12-hour scale (AM/PM) by clicking on the switch. If it is on, then the 24-hour scale is on, if off then otherwise.</p>
<p class="has-line-data" data-line-start="13" data-line-end="18">Kilometers or miles metrics: By default, the dashboard shows you data in Miles in the ‘Number of rides by binned distance (mi/km)’ bar chart and table. If you want to see distance in kilometers, by clicking on the switch next to “kilometers” the dashboard will convert miles to kilometers for you on both graph and table.<br>
Which rides to display: has three options “Total”, “From” and “To”. By default, the map will show you total trips on the map with a lower number of rides colored in yellow, and a higher number of rides colored in red. By clicking on “From” the map will display the number of rides From the areas, and by clicking on “To” the map will display the number of rides To the areas.<br>
Data visualizations:<br>
There are seven graphs and all of them have corresponding tables. Each graph and table has a title so it is easy to understand what it shows.<br>
The map is displayed on the right side of the dashboard. It displays all community areas of Chicago. By hovering on one of them it will highlight the area’s borders and show the popup as the number of rides. If you click on a certain community area, then it will automatically be shown on the bar charts and tables.</p>
<p class="has-line-data" data-line-start="19" data-line-end="80">1+ page worth of text on the data you used, including where you got it, what manipulations you did to it. This should be detailed enough to allow any reasonably computer literate person to reproduce what you did<br>
Versions<br>
R version 4.1.2 (2021-11-01) – “Bird Hippie” <a href="https://repo.miserver.it.umich.edu/cran/">https://repo.miserver.it.umich.edu/cran/</a><br>
RStudio (2021.09.2) – “Ghost Orchid” <a href="https://www.rstudio.com/products/rstudio/">https://www.rstudio.com/products/rstudio/</a><br>
Shiny version ‘1.7.1’<br>
Downloads<br>
How to download R: <a href="https://www.r-project.org">https://www.r-project.org</a><br>
How to download RStudio: <a href="https://www.rstudio.com/products/rstudio/download/">https://www.rstudio.com/products/rstudio/download/</a><br>
How to setup Shiny App: <a href="https://shiny.rstudio.com/articles/build.html">https://shiny.rstudio.com/articles/build.html</a><br>
Download data for this project (csv format): <a href="https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy">https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy</a><br>
Download boundaries of Chicago Community Areas: <a href="https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6">https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6</a><br>
Install libraries<br>
Run these commands in your RStudio console to install the packages:<br>
install.packages(‘shinydashboard’)<br>
install.packages(‘shinyWidgets’)<br>
install.packages(‘data.table’)<br>
install.packages(‘lubridate’)<br>
install.packages(‘ggplot2’)<br>
install.packages(‘leaflet’)<br>
install.packages(‘rgdal’)<br>
install.packages(‘shiny’)<br>
install.packages(‘DT’)<br>
Data<br>
The original data can be found on the Chicago Data Portal. The 2019 statistics can be found here: <a href="https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy">https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy</a><br>
The data is 7 GB in size and comprises 16.5 million rows. Because of the pre-COVID time of Chicago Taxi transportation, data was only gathered from the 2019 year to depict an ‘average’ year.<br>
How to process data<br>
Main Overview Of How We processed Data:<br>
We used our own approach as of how to filter out and process all the data that we have. We have developed a nodejs program to handle all the filtering part as well as parts of R code to do the minor required alterations to the data.<br>
In this part of the document I will describe the main algorithm that we used to filter out data, process it and export to csv table ready to be used in the application.<br>
Nodejs Program Main Algorithm code:<br>
const fs = require(“fs”);<br>
const nReadlines = require(“n-readlines”);<br>
const broadbandLines = new nReadlines(“data.csv”);<br>
// line by line<br>
while ((line = broadbandLines.next())) {<br>
// parse to ASCII<br>
const lineStr = line.toString(“ascii”);<br>
// if first line -&gt; get columns array<br>
lineNumber === 1 &amp;&amp;<br>
columns.push(…lineStr.split(&quot;,&quot;)) &amp;&amp;<br>
setNeededColumns(lineStr.split(&quot;,&quot;)) &amp;&amp;<br>
wstream.write(arrayToCsvLine(neededColumns));<br>
// get values arr<br>
const values = lineStr.split(&quot;,&quot;);<br>
// get data object<br>
const data = arrsToObj(columns, values);<br>
// check if data is correct<br>
if (correctData(data)) {<br>
// get needed part from curr data<br>
const dataArr = getNeededDataArr(data);<br>
// process each row that we read<br>
Manipulator.process(getNeededDataObj(data));<br>
// increment the number of elements<br>
trueElsNum++;<br>
// save to csv<br>
wstream.write(arrayToCsvLine(dataArr));<br>
// show mem<br>
if (trueElsNum % 250000 === 0) showMemory();<br>
}<br>
lineNumber++;<br>
}</p>
<p class="has-line-data" data-line-start="81" data-line-end="82">Manipulator.exportAllTables();</p>
<p class="has-line-data" data-line-start="83" data-line-end="98">Basically, it consists of the main following steps:<br>
Reading a file line by line,<br>
Parsing that line into data object,<br>
Filtering &amp; processing that object,<br>
Saving that filtered object into new csv data file,<br>
Exporting all generated tables data into csv files.<br>
Let’s delve a bit deeper into these steps:<br>
Reading a file line by line:<br>
We are reading the whole 7Gb data file line by line by using a simple library package “n-readlines” that you can install by running “npm i n-readlines” and then the following:<br>
while ((line = broadbandLines.next())) will parse each line in the buffer which we then parsed by using “line.toString(“ascii”);” into ascii format, which is a regular string.<br>
Parsing that line into data object:<br>
After we obtained string representation of buffer that was read, we parse that line into an data object to be able to manipulate it inside NodeJS. To do that, we have created two functions that take care of that: getNeededDataArr, getNeededDataObj.<br>
First function returns the data values in form of array, whereas the second function returns the object with the following structure: {date, duration, miles, from_area, to_area, company, year, month, day, hour, minute}.<br>
Filtering &amp; processing that object:<br>
Filtering is done by comparing the data object through multiple conditions in if statement like so:</p>
<p class="has-line-data" data-line-start="99" data-line-end="110">if ( parseFloat(row[“Trip Miles”]) &gt;= 0.5 &amp;&amp;<br>
parseFloat(row[“Trip Miles”]) &lt;= 100 &amp;&amp;<br>
parseInt(row[“Trip Seconds”]) &lt;= 18000 &amp;&amp;<br>
parseInt(row[“Trip Seconds”]) &gt;= 60 &amp;&amp;<br>
row[“Pickup Community Area”] != false &amp;&amp;<br>
row[“Dropoff Community Area”] != false<br>
) {<br>
return true;<br>
} else {<br>
return false;<br>
}</p>
<p class="has-line-data" data-line-start="111" data-line-end="112">This if statement directly relates to the requirements stated on the project 3 website on which data to filter out.</p>
<p class="has-line-data" data-line-start="113" data-line-end="138">Processing is a complicated process which results in generating all the needed tables in csv format.<br>
Those include: eachDayTotalRides_table, eachHourTotalRides_table, hourDayMonthRidesToFromTable_table and all the other tables that we used to lower the use of cpu and memory for our project.<br>
By pre-generating these csv tables we are able to achieve a great performance and memory usage which results in fast page loading time and fast update of the elements in our visualization.<br>
Processing takes place on this line:<br>
“Manipulator.process(getNeededDataObj(data));”<br>
What it does is just passing our data object that we got from the previous step to the main Manipulator that is responsible for all the pre-generation of csv files for the project.<br>
In a nutshell, when we pass a data object to Manipulator, it looks which tables need to be appended with this object and specifically which information to append to them, and save all these information in a matrix format for each table for the future csv export.<br>
Saving that filtered object into new csv data file:<br>
When we filter out the needed data object and process it, we append it to the new csv file designated to hold all filtered elements.<br>
Exporting all generated tables data into csv files:<br>
After we have filtered &amp; processed all the data objects parsed from the main data file, we export pre-generated tables data into csv formatted tables. To achieve this, we firstly export columns as a first line in new csv file and then, we iterate through each data piece that we calculated and append it to file as a parsed csv line.<br>
How to install &amp; use this parser NodeJS Program?<br>
First of all, make sure you have NodeJS installed in your system.<br>
<a href="https://nodejs.org/en/download/">https://nodejs.org/en/download/</a><br>
Then, In order to install this program you should first download the source code from github: <a href="https://github.com/nickparov/cs424_project3_ParserFilter">https://github.com/nickparov/cs424_project3_ParserFilter</a><br>
Next, download original dataset file from chicago portal:<br>
<a href="https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy">https://data.cityofchicago.org/Transportation/Taxi-Trips-2019/h4cq-z3dy</a><br>
And place 7GB data downloaded file into the folder of the program that you downloaded in the previous step. Then, rename it as “data.csv”.<br>
After that: open your program folder and run following commands to install all needed dependencies: “npm install”.<br>
Then, run “node main.js” which will take about 3-5mins depending on your machine. This command will produce all the needed csv files for the application to run which you will find in “csv” folder after program finishes execution as well as “csv-HDMR_TO_FROM” folder which is going to have smaller set of files generated for hourDayMonthRidesToFrom Table which we use in our application.<br>
How to convert miles to kilometers:<br>
Open csv file ‘milageBinsTotalRides_table.csv’ in Excel.<br>
In the new column, use function “=CONVERT(A2,“km”,“mi”)”<br>
Instead of A2, paste the first cell with miles data.<br>
Drag down the converted cell and all miles are converted to kilometers.</p>
<p class="has-line-data" data-line-start="139" data-line-end="148">How to convert 24-hour time to 12-hour:<br>
Open csv file ‘eachHourTotalRides_table.csv’ in Excel.<br>
In the new column, on the same row as “00” write 12.<br>
In the same column, under 12, write 1 and drag down till the next 12 occurring.<br>
Check whether data is correlated to each other in the way that 00 and 12, 13 and 1, 23 and 11 are in the same rows.<br>
In the new column on the right write “AM” and drag down till 11. Next to the 12, write “PM” and drag down the cell till the end.<br>
Check whether data is mapped correctly.<br>
Name new columns as ‘hour_tw’ and ‘ampm’.<br>
Save the new modified file or replace the old one.</p>
<p class="has-line-data" data-line-start="149" data-line-end="156">Interesting Facts:<br>
One of the interesting things we found is that in general, the number of people going out and in the area is the same. This could be due to the fact that a lot of people take taxis to go somewhere and come back home, so the average number of rides to/from areas is around 50% for all Chicago community areas.<br>
Another thing is that the most ‘rideable’ areas were ‘The north side’, ‘the loop’ and ‘new west side’. These areas have the most number of all types of rides in 2019. We figured out that this might be because of the number of people living in that area. The population of ‘Near North Side’ is equal to 89,995 from 2018 data. While its neighboring area ‘Jefferson park’ has the population of 27,989 from 2018 data.<br>
The mileage of all trips is mostly around 0.4-0.6 miles and it decreases as the distance grows. The cause of this might be the taxi prices, since they usually charge for miles, so people get taxis to get around short distances. While the most popular duration time is about 4 to 5 minutes.<br>
Interestingly, that the most number of rides happened in March. This might be due to the Spring break and students going out more, or because March usually has good weather after a long winter and people in general want to go out more.<br>
Most rides happen during weekdays, and there are much less rides on weekends.<br>
Less rides happen at 5AM, and most of the rides happen during lunch time, peaking at 1PM.</p>