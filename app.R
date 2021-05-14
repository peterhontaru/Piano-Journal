#source("api.R")
source("global.R")

# to use within the Dashboard ValueBox as KPIs
calc_last_updated <- raw_data%>%summarise(Last_Updated = max(Date_Start))%>%pull()
calc_total_practice <- raw_data%>%summarise(Duration = round(sum(Duration)/60))%>%pull()
calc_average_practice <- round(calc_total_practice*60/as.numeric(today()-raw_data%>%summarise(Date_Start = min(Date_Start))%>%pull()))

# import the model
model <- readRDS(file = './model.rda')

# exclude known outliers
model_data2 <- model_data%>%
    filter(ABRSM != 7)%>%
    filter(Project != "Clementi - Sonatina no 3 - Mov 2")%>%
    filter(Project != "Bach - Minuet in G - 114")%>%
    droplevels()

# variables needed for modeling
predictions <- predict(model, model_data2)

mae = mae(model_data2%>%select(Duration)%>%pull(), predictions)
rmse = rmse(model_data2%>%select(Duration)%>%pull(), predictions)

# create custom title ("a" for link OR "div" for text)
title = "Piano Journal"
title_full <- tags$a(href = "https://www.youtube.com/channel/UCnsFyYF1tpBdwu6hE7U9Thg", img(src = "logo.png", title = "My piano themed YouTube channel", height = "50px", width = "50px"), 
                     title, target = "_blank", style = "color:white;")

# User interface ----------------------------------------------------------

ui <- dashboardPage(
    
    skin = "red",
    title = title,
    
    ## Header ----------------------------------------------------------
    dashboardHeader(title = title_full,
                    tags$li(class = "dropdown", tags$a(href = "mailto:PetrisorHontaru@gmail.com?subject=Piano App Enquiry",
                                                       icon("envelope-square"), "Reach out for enquiries")),
                    tags$li(class = "dropdown", tags$a(href = "https://www.youtube.com/channel/UCnsFyYF1tpBdwu6hE7U9Thg",
                                       icon("youtube"),  target = "_blank", "My piano videos")),
                    tags$li(class = "dropdown", tags$a(href = "https://uk.linkedin.com/in/peterhontaru",
                                       icon("linkedin"), target = "_blank", "LinkedIn")),
                    tags$li(class = "dropdown", tags$a(href = "https://github.com/peterhontaru/Piano-Journal",
                                       icon("github"), target = "_blank", "Github"))),
    
    ## Sidebar ----------------------------------------------------------
    dashboardSidebar(
        ### Menu ----------------------------------------------------------
        sidebarMenu(
            menuItem("Dashboard", icon = icon("clipboard"),
                     menuSubItem("timeline", tabName = "dashboard_timeline"),
                     menuSubItem("animation", tabName = "dashboard_animation")
                     ),
            menuItem("Practice sessions", icon = icon("poll"),
                     menuSubItem("previous 30 days", tabName = "dashboard_previous30"),
                     menuSubItem("consistency", tabName = "dashboard_consistency"),
                     menuSubItem("average practice session", tabName = "dashboard_avg_practice")
                     ),
            menuItem("What do I play?", icon = icon("poll"),
                     ### Filters ----------------------------------------------------------
                     menuSubItem("by genre", tabName = "dashboard_genre"),
                     menuSubItem("by composer", tabName = "dashboard_composer"),
                     menuSubItem("by piece", tabName = "dashboard_piece"),
                     sliderInput("date", "Date Range", min(as.Date("2019-01-01")), max(raw_data$Date_Start),
                                 value = c(min(as.Date("2019-01-01")), max(raw_data$Date_Start))),
                     selectInput("select_genre", "Genre", choices = c("All", "Baroque", "Classical", "Romantic", "Modern"), selected = "All")
                     ),
            menuItem("Repertoire", tabName = "dashboard_repertoire", icon = icon("user-friends")),
            menuItem("Predict time to learn", tabName = "dashboard_prediction", icon = icon("search"), badgeLabel = "hot!", badgeColor = "red")
        )
    ),
    
    ## Body ----------------------------------------------------------
    dashboardBody(
        
        # set body theme
        shinyDashboardThemes(theme = "grey_dark"),
        
        tags$head(tags$style(HTML('.popover-title{
                              color: #ff5252;
                              font-size: 18px;
                              background-color: #000000;
                              }
                              
                              .popover-content{
                              color: white;
                              background: #ff5252;
                              }'))),
        
        tabItems(
            ### Dashboards ----------------------------------------------------------
            #### Timeline ----------------------------------------------------------
            tabItem("dashboard_timeline",
                    fluidRow(
                        # pop over KPIs
                        bsPopover(id = "kpi_practice", title = "Total hours practiced",
                                  content = "Includes everything except piano lessons (~25-30 hours each year)",
                                  trigger = "hover", placement = "right", options = list(container = "body")),
                        bsPopover(id = "kpi_average", title = "Daily average practice",
                                  content = "Includes days without any practice; it will change to a yellow background if it falls below 60 minutes",
                                  trigger = "hover", placement = "left", options = list(container = "body")),
                        bsPopover(id = "kpi_last_updated", title = "Last date included",
                                  content = "Live connection through the Toggl API; it will change to a yellow background if there is no data in the last 7 days",
                                  trigger = "hover", placement = "left", options = list(container = "body")),
                        # KPIs
                        valueBoxOutput("kpi_practice", width = 4),
                        valueBoxOutput("kpi_average", width = 4),
                        valueBoxOutput("kpi_last_updated", width = 4)
                    ),
                    fluidRow(box(width = 12, title = "Piano journey - timeline and ABRSM piano exams", solidHeader = TRUE, plotOutput("timeline")))),
            
            #### Animation ----------------------------------------------------------
            tabItem("dashboard_animation",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "Each animated dot represents a piece's progress over time", 
                                                       img(src="timeline.gif", align = "center", height='500px', width="100%")))),
            
            ### Practice sessions ----------------------------------------------------------
            #### Previous 30 days ----------------------------------------------------------
            tabItem("dashboard_previous30",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "The dashed line indicates the daily average practice length over the last 30 days", plotlyOutput("previous30")))),
            
            #### consistency ----------------------------------------------------------
            tabItem("dashboard_consistency",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "The dashed line indicates the overall consistency, while the numbers indicate the total days without any practice within each month", plotlyOutput("consistency")))),
            
            #### avg_practice ----------------------------------------------------------
            tabItem("dashboard_avg_practice", fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "The dashed line indicates the overall average practice length", plotlyOutput("avg_practice")))),
            
            ### Practice habits ----------------------------------------------------------
            #### Genre ----------------------------------------------------------
            tabItem("dashboard_genre",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "All genres", plotlyOutput("genre")))),
            
            #### Composer ----------------------------------------------------------
            tabItem("dashboard_composer",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "Top 10 by practice duration", plotlyOutput("composer")))),
            
            #### Piece ----------------------------------------------------------
            tabItem("dashboard_piece",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "Top 10 by practice duration", plotlyOutput("piece")))),
            
            ### Repertoire ----------------------------------------------------------
            tabItem("dashboard_repertoire", fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "Repertoire", dataTableOutput("repertoire")))),
            
            #Prediction tab content
            tabItem('dashboard_prediction',
                    #Filters for categorical variables
                    box(title = 'About the piece', status = 'info', solidHeader = TRUE, width = 12,
                        splitLayout(tags$head(tags$style(HTML(".shiny-split-layout > div {overflow: visible;}"))),
                                    cellWidths = c('0%', '28%', '5%', '31%', '5%', '21%'),
                                    sliderInput('p_abrsm', 'Difficulty (ABRSM Grade)', min = 1, max = 6, value = 1),
                                    div(),
                                    sliderInput('p_length', 'Length (minutes)', min = 0, max = 5, step = 0.5, value = 1),
                                    div(),
                                    selectInput('p_genre', 'Genre', c('Romantic', 'Baroque', 'Classical', 'Modern'), selected = 'Romantic'))),
                    #Filters for numeric variables
                    box(title = 'About yourself', status = 'info', solidHeader = TRUE, width = 12,
                        splitLayout(cellWidths = c('40%', '10%', '40%', '10%'),
                                    selectInput('p_standard', 'How well would you like to learn it', c('Performance', 'Casual'), selected = 'Casual'),
                                    div(),
                                    sliderInput('p_cumulative_duration', 'Experience (estimate of total hours practiced)', min = 100, max = 3000, value = 500, step = 100))),
                    #Box to display the prediction results
                    box(title = 'Prediction result', status = 'danger', solidHeader = TRUE, width = 4, height = 290,
                        div(h5('Estimated hours of practice required:')),
                        verbatimTextOutput("value", placeholder = TRUE),
                        div(h5('Range of number of hours of practice required:')),
                        verbatimTextOutput("range", placeholder = TRUE),
                        actionButton('cal','Calculate', icon = icon('calculator'))),
                    #Box to display information about the model
                    box(title = 'Model explanation', status = 'danger', solidHeader = FALSE, width = 8, height = 290,
                        helpText('The following model will predict the total number of hours required to learn a piece based on the selected variables.'),
                        helpText('Given that the dataset was based solely on my own data, the model is biased towards my learning performance. In simple terms, it shows how fast I would have learnt a piece based on specific inputs.'),
                        helpText('However, the result will both be an estimate and a range. Hopefully you will find the range to be useful in your own journey. The prediction uses a Random Forest model.'),
                        helpText(sprintf('You can find an in-depth analysis on my'), a("GitHub.", href="https://github.com/peterhontaru/Piano-Journal/"))
                        )
                    )
            )
        )
    )

# Server ----------------------------------------------------------

server<- function(input, output, session) {
    
    ## dynamic datasets ----------------------------------------------------------
    filtered_data <- reactive({
        # # filter by Genre (if ALL not selected)
        if (input$select_genre != "All") {
            raw_data <- subset(raw_data, Genre == input$select_genre)
        }
        # filter by Date Range
        raw_data%>%
            filter(Date_Start >= input$date[1] & Date_End <= input$date[2])
    })
    
    ## create functions ----------------------------------------------------------
    graph_practice <- function(variable, nudge){
        filtered_data()%>%
            filter(Genre %notin% c("Other", "Not applicable"))%>%
            group_by({{variable}})%>%
            summarise(Duration = as.integer(sum(Duration)/60))%>%
            arrange(desc(Duration))%>%
            head(10)%>%
            
            ggplot(aes(reorder({{variable}}, Duration), Duration, fill = Duration))+
            geom_col(show.legend = FALSE, col = "black", width = 1)+
            geom_text(aes(label = Duration), show.legend = FALSE, nudge_y = nudge, size = 5)+
            scale_fill_gradient(low="yellow", high="red")+
            labs(x = NULL,
                 y = "Total hours of practice")+
            coord_flip()+
            theme_minimal()+
            theme(axis.text.x = element_blank(),
                  axis.ticks = element_blank())
        
        ggplotly()
    }
    
    ## Dashboards ----------------------------------------------------------
    ### timeline ----------------------------------------------------------
    #### first KPI ----------------------------------------------------------
    output$kpi_practice <- renderValueBox({
        valueBox(
            value = calc_total_practice%>%prettyNum(big.mark = ","),
            subtitle = "Total hours practiced",
            icon = icon("lightbulb-o"),
            color = "green"
        )
    })
    #### second KPI ----------------------------------------------------------
    output$kpi_average <- renderValueBox({
        valueBox(
            value = paste(calc_average_practice, "min", sep = " "),
            subtitle = "Daily average practice",
            icon = icon("fire"),
            color = if (calc_average_practice >= 60) "green" else "yellow"
        )
    })
    #### third KPI ----------------------------------------------------------
    output$kpi_last_updated <- renderValueBox({
        valueBox(
            calc_last_updated,
            "Last date included",
            icon = icon("refresh", class = "fa-spin"),
            color = if (today() - calc_last_updated <= 7) "green" else "yellow"
        )
    })
    #### timeline plot ----------------------------------------------------------
    output$timeline <- renderPlot({
        raw_data%>%
            group_by(Month_Year)%>%
            summarise(Total_Duration = sum(Duration)/60)%>%
            mutate(Total_Duration2 = as.integer(cumsum(Total_Duration)),
                   max = as.integer(max(Total_Duration2)),
                   max2 = ifelse(max > Total_Duration2, "", "today"))%>%
            
            ggplot(aes(Month_Year, Total_Duration2, group = 1))+
            geom_line(size = 2, color = "#69b3a2")+
            geom_point(size = 5, color = "#69b3a2")+
            geom_area(alpha = 0.3, fill = "#69b3a2")+
            # tracked vs estimated
            geom_segment(aes(x = "Nov 2018", xend = "Nov 2018", y = 282, yend = 0), lty = "dashed", alpha = 0.5, col = "gray52")+
            geom_text(x="Aug 2018", y = 202/2,  size = 5.5, label = "estimated", col = "gray52")+
            geom_text(x="Feb 2019", y = 202/2,  size = 5.5, label = "tracked", col = "gray52")+
            # grade 3
            geom_point(x="Oct 2018", y = 253, size = 9, shape = 21, fill = "dark red", col = "black")+
            geom_text(x="Oct 2018", y = 253+200, size = 5.5, label = "Grade 3")+
            geom_text(x="Oct 2018", y = 253+100,  size = 5.5, label = "253 hours")+
            # grade 5
            geom_point(x="Oct 2019", y = 675, size = 9, shape = 21, fill = "dark red", col = "black")+
            geom_text(x="Oct 2019", y = 675+200,  size = 5.5, label = "Grade 5")+
            geom_text(x="Oct 2019", y = 675+100,  size = 5.5, label = "675 hours")+
            # grade 6
            geom_point(x="Oct 2020", y = 1078, size = 9, shape = 21, fill = "dark red", col = "black")+
            geom_text(x="Oct 2020", y = 1078+200,  size = 5.5, label = "Grade 6")+
            geom_text(x="Oct 2020", y = 1078+100,  size = 5.5, label = "1078 hours")+
            coord_cartesian(ylim = c(0, calc_total_practice+50))+
            labs(x = NULL,
                 y = "Total hours of practice")+
            theme_minimal()+
            theme(legend.position = "top",
                  axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
    })
    
    ## Practice sessions ----------------------------------------------------------
    ### previous 30 days dashboard ----------------------------------------------------------
    output$previous30 <- renderPlotly({
        raw_data%>%
            filter(Date_Start > today()-30)%>%
            group_by(Date_Start, Project)%>%
            summarise(Duration = sum(Duration))%>%
            ungroup()%>%
            mutate(Average = sum(Duration)/30)%>%
            
            ggplot(aes(Date_Start, Duration, fill = Project))+
            geom_hline(aes(yintercept = Average+5), lty = "dashed", alpha = 0.25)+
            #geom_text(x = today()+0.25, aes(y = Average+7),  size = 3, label = "30 day\naverage")+
            geom_col(col = "black")+
            labs(x = NULL,
                 y = "Practice time")+
            scale_fill_tron()+
            theme_minimal()+
            theme(legend.position = "top")
        
        ggplotly()
    })
    
    ### consistency ----------------------------------------------------------
    output$consistency <- renderPlotly({raw_data%>%
            filter(Source != "Estimated")%>%
            mutate(current_month = as.factor(ifelse(Month_Start == max(Month_Start), "Yes", "No")))%>%
            group_by(Month_Year, Month_Start, Month_format, current_month)%>%
            summarise(Days_Practice = n_distinct(Date_Start),
                      Total_Duration = sum(Duration))%>%
            mutate(Days_Total = ifelse(current_month == "Yes", day(today()), days_in_month(Month_Start)), # account for the fact that the current month is incomplete
                   Days_Not_Practiced = Days_Total - Days_Practice,
                   Avg_Duration = as.integer(Total_Duration/Days_Total),
                   Consistency = round(Days_Practice / Days_Total * 100,2),
                   Consistency_Status = ifelse(Consistency>=75, "over 75%", "under 75%"),
                   Consistency_Status = factor(Consistency_Status, levels = c("under 75%", "over 75%")),
                   Month_format = reorder(Month_format, Month_Year))%>%
            ungroup()%>%
            mutate(Average = sum(Days_Practice)/sum(Days_Total)*100)%>%
            
            ggplot(aes(Month_Year, Consistency, fill = Consistency_Status))+
            geom_hline(aes(yintercept = Average), lty = "dashed", alpha = 0.25)+
            geom_col(group = 1, col = "black")+
            geom_text(aes(label = Days_Not_Practiced), size = 4, nudge_y = 3, show.legend = FALSE)+
            #geom_text(x = "Mar\n '21", aes(y = Average+3),  size = 4, label = "average")+
            labs(x = NULL,
                 fill = NULL)+
            scale_fill_tron()+
            theme_minimal()+
            theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
        
        ggplotly()%>%
            layout(legend = list(orientation = "h", x = 0.4, y = 1.2))
    })
    
    ### average session ----------------------------------------------------------
    output$avg_practice <- renderPlotly({
        raw_data%>%
            filter(Source != "Estimated")%>%
            mutate(current_month = as.factor(ifelse(Month_Start == max(Month_Start), "Yes", "No")))%>%
            group_by(Month_Year, Month_Start, Month_format, current_month)%>%
            summarise(Days_Practice = n_distinct(Date_Start),
                      Total_Duration = sum(Duration))%>%
            mutate(Days_Total = ifelse(current_month == "Yes", day(today()), days_in_month(Month_Start)), # account for the fact that the current month is incomplete
                   Avg_Duration = as.integer(Total_Duration/Days_Total),
                   Avg_Duration_Status = ifelse(Avg_Duration < 60, "under one hour", "over one hour"),
                   Avg_Duration_Status = factor(Avg_Duration_Status, levels = c("under one hour", "over one hour")),
                   Month_format = reorder(Month_format, Month_Year))%>%
            ungroup()%>%
            mutate(Average = sum(Total_Duration)/sum(Days_Total))%>%
            
            ggplot(aes(Month_Year, Avg_Duration, fill = Avg_Duration_Status))+
            geom_hline(yintercept = 60, lty = "dashed", alpha = 0.25)+
            geom_col(col = "black")+
            labs(x = NULL,
                 y = "Average daily practice (minutes)",
                 fill = NULL)+
            geom_text(aes(label = Avg_Duration), nudge_y = 5, size = 4)+
            #geom_text(x = "Mar\n '21", aes(y = Average+3),  size = 4, label = "average")+
            scale_fill_tron()+
            theme_minimal()+
            theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
                  axis.text.y = element_blank(),
                  axis.ticks.y = element_blank())

        ggplotly()%>%
            layout(legend = list(orientation = "h", x = 0.4, y = 1.2))
    })
    
    ## Practice habits ----------------------------------------------------------
    ### by genre ----------------------------------------------------------
    output$genre <- renderPlotly({
        graph_practice(Genre, 15)
    })
    
    ### by composer ----------------------------------------------------------
    output$composer <- renderPlotly({
        graph_practice(Composer, 4)
    })
    
    ### by piece ----------------------------------------------------------
    output$piece <- renderPlotly({
        graph_practice(Project, 2)
    })
    
    ## Repertoire ----------------------------------------------------------
    output$repertoire <- renderDataTable({
        model_data%>%
            select(-Project, -Days_Practiced, -Max_Break, -Break)%>%
            mutate(Duration = round(Duration, 1),
                   Project = Link,
                   Length = round(Length,1))%>%
            arrange(desc(Date_End))%>%
            rename(Practice = Duration,
                   Experience = Cumulative_Duration,
                   `First practice` = Date_Start,
                   `Last practice` = Date_End)%>%
            select(-Link)%>%
            as.data.table()
            }, 
        escape = FALSE
        )
    
    ## Prediction model ----------------------------------------------------------
    #React value when using the action button
    a <- reactiveValues(result = NULL)
    
    observeEvent(input$cal, {
        #Copy of the test data without the dependent variable
        model_pred <- model_data2 %>% ungroup() %>% select(ABRSM, Genre, Cumulative_Duration, Standard, Length)
        
        #Dataframe for the single prediction
        values = data.frame(ABRSM = input$p_abrsm,
                        Genre = input$p_genre,
                        Cumulative_Duration = input$p_cumulative_duration,
                        Standard = input$p_standard,
                        Length = input$p_length)
    
        #Included the values into the new data
        model_pred <- rbind(model_pred, values)
    
        #Single prefiction using the randomforest model
        a$result <-  round(predict(model, 
                                   newdata = model_pred[nrow(model_pred),]),
                           digits = 0)
    })
    
    output$value <- renderText({
        #Display the prediction value
        paste(a$result)
    })
    
    output$range <- renderText({
        #Display the range of prediction value using the MAE value
        input$cal
        isolate(sprintf('(%s) - (%s)', 
                        round(a$result - mae, digits = 0), 
                        round(a$result + mae, digits = 0)))
    })
    
}

# Create the shiny app ----------------------------------------------------------

shinyApp(ui = ui, server = server)