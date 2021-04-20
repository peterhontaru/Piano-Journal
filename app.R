library(dashboardthemes) #get the theme
library(shinythemes)
library(thematic) #theme? no tused
library(bslib) #theme? not used

#get the clean data
source("global.R")

# to use as KPI on dashboard
calc_last_updated <- raw_data%>%summarise(Last_Updated = max(Date_End))%>%pull()

# import the model
model <- readRDS(file = './model.rda')

# exclude grade 7 pieces from predictions
model_data2 <- model_data%>%filter(ABRSM != 7)

# variables needed for modeling
predictions <- predict(model, model_data2)

mae = mae(model_data2%>%select(Duration)%>%pull(), predictions)
rmse = rmse(model_data2%>%select(Duration)%>%pull(), predictions)

#about dialog box
text_about <- tags$div(
    "This report was developed by Peter Hontaru (PetrisorHontaru@gmail.com) and it is currently under testing.", br(),br(),
    "If you have any questions, please contact me via email by clicking on the icon at the top right of this report.")

#create custom title ("a" for link OR "div" for text); target parameter creates a new tab for the link
title <- tags$a(href = "https://www.youtube.com/channel/UCnsFyYF1tpBdwu6hE7U9Thg", img(src = "logo.png", title = "My piano themed YouTube channel", height = "50px", width = "50px"), 
                "Piano Journey", target = "_blank", style = "color:white;")

# User interface ----------------------------------------------------------

ui <- dashboardPage(
    
    skin = "red",
    
    ## Header ----------------------------------------------------------
    dashboardHeader(title = title,
                    tags$li(class = "dropdown", tags$a(href = "mailto:PetrisorHontaru@gmail.com?subject=Piano App Enquiry",
                                                       icon("envelope-square"), "Reach out for enquiries")),
                    tags$li(class = "dropdown", tags$a(href = "https://www.youtube.com/channel/UCnsFyYF1tpBdwu6hE7U9Thg",
                                       icon("youtube"),  target = "_blank", "More piano playing")),
                    tags$li(class = "dropdown", tags$a(href = "https://uk.linkedin.com/in/peterhontaru",
                                       icon("linkedin"), target = "_blank", "LinkedIn")),
                    tags$li(class = "dropdown", tags$a(href = "https://github.com/peterhontaru",
                                       icon("github"), target = "_blank", "Github"))),
    
    ## Sidebar ----------------------------------------------------------
    dashboardSidebar(
        ### Filters ----------------------------------------------------------
        sliderInput("date", "Date Range", min(raw_data$Date_Start), max(raw_data$Date_Start),
                    value = c(min(raw_data$Date_Start), max(raw_data$Date_Start))),
        selectInput("genre", "Genre", choices = c("All", as.character(unique(raw_data$Genre))), selected = "All"),
        #sliderInput("top", label = "Max number of groups to plot", min = 1, max = 10, value = 4),
        ### Menu ----------------------------------------------------------
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard", icon = icon("clipboard"), badgeLabel = "new", badgeColor = "green"),
            menuItem("Practice sessions", icon = icon("poll"),
                     menuSubItem("Consistency", tabName = "dashboard_consistency"),
                     menuSubItem("Average daily practice", tabName = "dashboard_avg_practice")
                     ),
            menuItem("What do I play?", icon = icon("poll"),
                     menuSubItem("by genre", tabName = "dashboard_genre"),
                     menuSubItem("by composer", tabName = "dashboard_composer"),
                     menuSubItem("by piece", tabName = "dashboard_piece")
                     ),
            menuItem("Repertoire learnt", tabName = "dashboard_repertoire", icon = icon("user-friends"), badgeLabel = "new", badgeColor = "green"),
            menuItem("Predict time to learn", tabName = "dashboard_prediction", icon = icon("search"), badgeLabel = "new", badgeColor = "green"),
            #menuItem("Raw data", tabName = "rawdata", badgeLabel = "out of use", badgeColor = "red"),
            actionButton("show_about", "About")
        )
    ),
    
    ## Body ----------------------------------------------------------
    dashboardBody(
        
        # set body theme
        shinyDashboardThemes(theme = "grey_dark"),
        
        tags$head(tags$style(HTML('.popover-title{
                              color: #ffff99;
                              font-size: 18px;
                              background-color: #000000;
                              }
                              
                              .popover-content{
                              color: #666666;
                              background: #ffff99;
                              }'))),
        
        tabItems(
            ### Main dashboard ----------------------------------------------------------
            tabItem("dashboard",
                    fluidRow(
                        #pop over KPIs
                        bsPopover(id = "kpi_opened_cases", title = "Opened Cases",
                                  content = "Total cases opened",
                                  trigger = "hover", placement = "right", options = list(container = "body")),
                        bsPopover(id = "kpi_sl", title = "Service Level",
                                  content = "Total cases opened still within or closed within Service Level",
                                  trigger = "hover", placement = "left", options = list(container = "body")),
                        bsPopover(id = "kpi_last_updated", title = "Last Updated",
                                  content = "Last time the raw data was refreshed",
                                  trigger = "hover", placement = "left", options = list(container = "body")),
                        #KPIs
                        valueBoxOutput("kpi_opened_cases", width = 4),
                        valueBoxOutput("kpi_sl", width = 4),
                        valueBoxOutput("kpi_last_updated", width = 4)
                    ),
                    fluidRow(tabBox(width = 8, title = "Dashboard (hover over the plot for more information)", side = "right", selected = "Service Level",
                                    tabPanel("Service Level", plotOutput("plotly_sl")),
                                    tabPanel("Hours to close", plotlyOutput("plotly_asa")),
                                    tabPanel("Re-opened", plotlyOutput("plotly_reopened"))),
                             box(width = 4, status = "info", solidHeader = FALSE, title = "Overall Status by Department", collapsible = T, tableOutput("packageTable")))),
            
            ### consistency ----------------------------------------------------------
            tabItem("dashboard_consistency",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, 
                                                   title = "by genre", plotOutput("consistency")))),
            
            ### avg_practice ----------------------------------------------------------
            tabItem("dashboard_avg_practice", fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "by composer", plotOutput("avg_practice")))),
            
            ### Genre ----------------------------------------------------------
            tabItem("dashboard_genre",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "by genre", plotOutput("genre")))),
            
            ### Composer ----------------------------------------------------------
            tabItem("dashboard_composer",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "by composer", plotOutput("composer")))),
            
            ### Piece ----------------------------------------------------------
            tabItem("dashboard_piece",fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "by piece", plotOutput("piece")))),
            
            ### Repertoire ----------------------------------------------------------
            tabItem("dashboard_repertoire", fluidRow(box(width = 12, status = "info", solidHeader = TRUE, title = "Repertoire", tableOutput("repertoire")))),
            
            #Prediction tab content
            tabItem('dashboard_prediction',
                    #Filters for categorical variables
                    box(title = 'About the piece', status = 'info', solidHeader = TRUE, width = 12,
                        splitLayout(tags$head(tags$style(HTML(".shiny-split-layout > div {overflow: visible;}"))),
                                    cellWidths = c('0%', '20%', '2.5%', '35%', '2.5%', '35%', '2.5%', '10%'),
                                    sliderInput('p_abrsm', 'ABRSM Grade', min = 1, max = 8, value = 1),
                                    div(),
                                    textInput('p_standard', 'How well would you like to learn it', "Performance"),
                                    div(),
                                    selectInput('p_genre', 'Genre', c('Romantic', 'Baroque', 'Classical', 'Modern')))),
                    
                    #Filters for numeric variables
                    box(title = 'About yourself', status = 'info', solidHeader = TRUE, width = 12,
                        splitLayout(cellWidths = c('10%', '2.5%','25%', '7.5%', '35%', '5%', '30%', '5%'),
                                    numericInput('p_length', 'Length (mins)', value = "Yes"),
                                    div(),
                                    textInput('p_break2', 'Do you intend to take a break longer than 1 month?', "Yes"),
                                    div(),
                                    numericInput('p_cumulative_duration', 'Experience (estimate of total hours practiced)', min = 0, max = 1200, 100))),
                    #Box to display the prediction results
                    box(title = 'Prediction result', status = 'danger', solidHeader = TRUE, width = 4, height = 260,
                        div(h5('Estimated hours of practice required:')),
                        verbatimTextOutput("value", placeholder = TRUE),
                        div(h5('Range of number of hours of practice required:')),
                        verbatimTextOutput("range", placeholder = TRUE),
                        actionButton('cal','Calculate', icon = icon('calculator'))),
                    #Box to display information about the model
                    box(title = 'Model explanation', status = 'danger', solidHeader = FALSE, width = 8, height = 260,
                        helpText('The following model will predict the total number of hours required to learn a piece based on the selected variables.'),
                        helpText('Given that the dataset was based solely on my own data, the model is biased towards my learning performance. In simple terms, it shows how fast I would have learnt a piece based on specific inputs.'),
                        helpText('However, the result will both be an estimate and a range. Hopefully you will find the range to be useful in your own journey. The prediction uses the Random Forrest model.'),
                        helpText(sprintf('You can find the analysis and the modelling used for this prediction on my GitHub https://github.com/peterhontaru', 
                        2, 3)))),
                                         #round(mae, digits = 0), round(rmse, digits = 0))))),
            
            ### Raw data ----------------------------------------------------------
            #data.table function?
            tabItem("rawdata", numericInput("maxrows", "Rows to show", 15), verbatimTextOutput("rawtable"),
                    downloadButton("downloadCsv", "Download as CSV"))
        )
    )
)

# Server ----------------------------------------------------------

server<- function(input, output, session) {
    
    ## dynamic dataset ----------------------------------------------------------
    filtered_data <- reactive({
        # filter by Department (if ALL not selected)
        # if (input$Genre != "All") {
        #     raw_data <- subset(raw_data, Genre == input$Genre)
        # }
        raw_data%>%
            filter(Date_Start >= input$date[1] & Date_End <= input$date[2])
    })
    
    ### advisor dataset ----------------------------------------------------------
    filtered_data_advisor <- reactive({
        filtered_data()%>%
            group_by(Case_Owner, Department)%>%
            summarise(count = sum(n()))%>%
            ungroup()%>%
            mutate(Case_Owner = reorder(Case_Owner, count))%>%
            arrange(desc(count))%>%
            head(15)
    })
    
    ### create functions ----------------------------------------------------------
    
    ### create dynamic variables ----------------------------------------------------------
    calc_opened_cases <- reactive({filtered_data()%>%summarise(Duration = round(sum(Duration)/60))%>%pull()%>%prettyNum(big.mark = ",")})
    calc_sl <- reactive({filtered_data()%>%group_by(Date_Start)%>%summarise(Duration = sum(Duration))%>%summarise(Duration = round(mean(Duration)))%>%pull()}) #account for non practice days
    
    ## MAIN PAGE ----------------------------------------------------------
    
    ### first KPI ----------------------------------------------------------
    output$kpi_opened_cases <- renderValueBox({
        valueBox(
            value = calc_opened_cases(),
            subtitle = "Total hours practiced",
            icon = icon("lightbulb-o"),
            color = "green"
        )
    })
    
    ### second KPI ----------------------------------------------------------
    output$kpi_sl <- renderValueBox({
        valueBox(
            value = paste(calc_sl(), "%", sep = ""),
            subtitle = "Consistency",
            icon = icon("fire"),
            color = if (calc_sl() >= 80) "green" else "yellow"
        )
    })
    
    ### third KPI ----------------------------------------------------------
    output$kpi_last_updated <- renderValueBox({
        valueBox(
            calc_last_updated,
            "Last date included",
            icon = icon("refresh", class = "fa-spin"),
            color = "green"
        )
    })
    
    ### summary table ----------------------------------------------------------
    output$packageTable <- renderTable({
        filtered_data() %>%
            group_by(Genre)%>%
            summarise(Duration = sum(Duration))%>%
            as.data.frame()
    })
    
    ### timeline plot ----------------------------------------------------------
    output$plotly_sl <- renderPlot({
        filtered_data()%>%
            group_by(Month_format)%>%
            summarise(Total_Duration = sum(Duration)/60)%>%
            mutate(Total_Duration2 = cumsum(Total_Duration),
                   max = as.integer(max(Total_Duration2)),
                   max = ifelse(max > Total_Duration2, "", max))%>%
            
            #correct exam dates
            #can be automated ifelse?
            
            #untracked (vertical line)
            ggplot(aes(Month_format, Total_Duration2, group = 1))+
            geom_line(size = 2, color = "#69b3a2")+
            geom_point(size = 5, color = "#69b3a2")+
            geom_area(alpha = 0.3, fill = "red")+
            #grade 3
            geom_point(x="Oct\n '19", y = 393.28333, size = 5, color = "dark red")+
            geom_text(x="Oct\n '19", y = 443.28333, label = "Grade 3")+
            #grade 5
            geom_point(x="Oct\n '20", y = 795.86667, size = 5, color = "dark red")+
            geom_text(x="Oct\n '20", y = 840.86667,  size = 5, label = "Grade 5")+
            geom_text(x="Oct\n '20", y = 745.86667,  size = 5, label = "840 hours")+
            #current hours
            geom_text(aes(label = max), nudge_y = -25, nudge_x = -0.25, size = 5)+
            
            labs(x = NULL,
                 fill = "Status",
                 title = "Piano practice timeline")+
            theme_few()+
            theme(legend.position = "top")
    })
    
    ## consistency ----------------------------------------------------------
    output$consistency <- renderPlot({
        filtered_data()%>%
            filter(Source != "Estimated")%>%
            group_by(Month_Year, Month_Start, Month_format)%>%
            summarise(Days_Practice = n_distinct(Date_Start),
                      Total_Duration = sum(Duration, na.rm = TRUE))%>%
            mutate(Days_Total = days_in_month(Month_Start),
                   Days_Not_Practiced = Days_Total - Days_Practice,
                   Avg_Duration = as.integer(Total_Duration/Days_Total),
                   Consistency = round(Days_Practice / Days_Total * 100,2),
                   Consistency_Status = ifelse(Consistency<75, "Bad", "Good"),
                   Month_format = reorder(Month_format, Month_Year))%>%
            
            ggplot(aes(Month_format, Consistency, fill = Consistency_Status))+
            geom_col(group = 1, col = "black")+
            geom_hline(yintercept = 75, lty = "dashed")+
            geom_text(aes(label = Days_Not_Practiced), size = 5, nudge_y = 3)+
            labs(x = NULL,
                 fill = "Consistency status",
                 subtitle = "Numbers indicate days without any practice within each month")+
            scale_color_tron()+
            scale_fill_tron()+
            theme_few()+
            theme(legend.position = "top")
    })
    
    ## average session ----------------------------------------------------------
    output$avg_practice <- renderPlot({
        filtered_data()%>%
            filter(Source != "Estimated")%>%
            group_by(Month_Year, Month_Start, Month_format)%>%
            summarise(Days_Practice = n_distinct(Date_Start),
                      Total_Duration = sum(Duration))%>%
            mutate(Days_Total = days_in_month(Month_Start),
                   Avg_Duration = as.integer(Total_Duration/Days_Total),
                   Avg_Duration_Status = ifelse(Avg_Duration < 60, "Less than one hour", "One hour"),
                   Month_format = reorder(Month_format, Month_Year))%>%
            
            ggplot(aes(Month_format, Avg_Duration, fill = Avg_Duration_Status))+
            geom_col(col = "black")+
            labs(x = NULL,
                 y = "Average practice session length (min)",
                 fill = "Status")+
            geom_text(aes(label = Avg_Duration), nudge_y = 5, size = 5)+
            scale_color_tron()+
            scale_fill_tron()+
            theme_few()+
            theme(legend.position = "top",
                  axis.text.y = element_blank(),
                  axis.ticks.y = element_blank())
    })
    
    ## by genre ----------------------------------------------------------
    output$genre <- renderPlot({
        filtered_data()%>%
            group_by(Genre)%>%
            summarise(Duration = as.integer(sum(Duration)/60))%>%
            mutate(Genre = reorder(Genre, Duration))%>%
            arrange(desc(Duration))%>%
            filter(Genre %notin% c("Other", "Not applicable"))%>%
            head(10)%>%
            
            ggplot(aes(Genre, Duration, fill = Duration))+
            geom_col(show.legend = FALSE, col = "black", width = 1)+
            geom_text(aes(label = Duration), show.legend = FALSE, nudge_y = 25)+
            scale_fill_gradient(low="yellow", high="red")+
            labs(x = NULL,
                 y = "Total hours of practice",
                 subtitle = "*Not applicable* - unclassified practice and *Other* - sight reading + technique practice")+
            coord_flip()+
            theme_few()
    })
    
    ## by composer ----------------------------------------------------------
    output$composer <- renderPlot({
        filtered_data()%>%
            filter(Composer != "Not applicable")%>%
            group_by(Composer)%>%
            summarise(Duration = as.integer(sum(Duration)/60))%>%
            mutate(Composer = reorder(Composer, Duration))%>%
            arrange(desc(Duration))%>%
            head(10)%>%
            
            ggplot(aes(Composer, Duration, fill = Duration))+
            geom_col(show.legend = FALSE, col = "black", width = 1)+
            geom_text(aes(label = Duration), show.legend = FALSE, nudge_y = 6)+
            scale_fill_gradient(low="yellow", high="red")+
            labs(x = NULL,
                 y = "Total hours of practice",
                 subtitle = "*Not applicable* - unclassified practice and *Other* - sight reading + technique practice")+
            coord_flip()+
            theme_few()
    })
    
    ## by piece ----------------------------------------------------------
    output$piece <- renderPlot({
        filtered_data()%>%
            group_by(Project)%>%
            summarise(Duration = as.integer(sum(Duration)/60))%>%
            mutate(Project = reorder(Project, Duration))%>%
            arrange(desc(Duration))%>%
            filter(Project %notin% c("Technique", "General", "Sightreading"))%>%
            head(15)%>%
            
            ggplot(aes(Project, Duration, fill = Duration))+
            geom_col(show.legend = FALSE, col = "black", width = 1)+
            geom_text(aes(label = Duration), show.legend = FALSE, nudge_y = 2)+
            scale_fill_gradient(low="yellow", high="red")+
            labs(x = NULL,
                 y = "Total hours of practice",
                 title = "Top 15 pieces by hours of practice")+
            coord_flip()+
            theme_few()
    })
    
    ## Advisor ----------------------------------------------------------
    output$repertoire <- renderTable({
        model_data%>%
            select(-Project)%>%
            as.data.table()
    })
    
    #Show an about report box
    observeEvent(input$show_about, {
        showModal(modalDialog(text_about, title = 'Report information'))
    })
    
    ## Prediction model ----------------------------------------------------------
    #React value when using the action button
    a <- reactiveValues(result = NULL)
    
    observeEvent(input$cal, {
        #Copy of the test data without the dependent variable
        model_pred <- model_data2 %>% ungroup() %>% select(ABRSM, Genre, Break, Cumulative_Duration, Standard, Length, -Project)
        
        #Dataframe for the single prediction
        values = data.frame(ABRSM = input$p_abrsm,
                        Genre = input$p_genre,
                        Break = input$p_break2,
                        Cumulative_Duration = input$p_cumulative_duration,
                        Standard = input$p_standard,
                        Length = input$p_length)
    
        #Included the values into the new data
        model_pred <- rbind(model_pred, values)
    
        #Single preiction using the randomforest model
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




rsconnect::appDependencies()
# Other ----------------------------------------------------------

# Download data https://www.youtube.com/watch?v=ux2tQqgY8Gg&list=PLg2IaQ2n7d1UjM8Re4N_zGbPb3avluw_T&index=6

# About me page with picture and video, context, description (picture Chirstmas piano), 

# video somewhere on timeline?

# last few sessions on the dashboard (one tab as previous 7/14 days)

# logo design by "https://brandsawesome.com/project/play-piano-logo-concept/"
# tutorial https://towardsdatascience.com/how-to-use-r-shiny-for-eda-and-prediction-72e6ef842240

# Testing ----------------------------------------------------------
# shinyloadtest::record_session('http://127.0.0.1:4031/')

# 
# * Gantt chart for each piece ||||| || ||||||| map for practice sessions by time (maybe low intensity background)
# * Don't use comments to say what/how your code is doing, use it to describe why. Otherwise, you have to remember to change comments when you change your code.