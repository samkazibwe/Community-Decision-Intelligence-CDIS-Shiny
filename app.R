# app.R - CDIS Shiny
library(shiny)
source("packages.R")
source("R/utils.R")
source("R/recommendation_engine.R")

ui <- fluidPage(theme=shinythemes::shinytheme("flatly"),
  titlePanel("Community Decision Intelligence — Masindi & Kiryandongo"),
  sidebarLayout(
    sidebarPanel(
      fileInput("upload", "Upload outreach CSV (Kobo/DHIS2 export)", accept=".csv"),
      selectInput("facility", "Facility", choices=NULL),
      radioButtons("period", "Recent window", choices=c("30 days"=30, "60 days"=60, "90 days"=90), selected=90),
      actionButton("refresh", "Recompute Insights")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Overview", 
                 fluidRow(column(6, plotlyOutput("trend_plot") %>% withSpinner()),
                          column(6, DTOutput("key_metrics") %>% withSpinner())),
                 hr(),
                 h4("Actionable Recommendation"),
                 verbatimTextOutput("recommendation")
        ),
        tabPanel("Anomalies", DTOutput("anomaly_table")),
        tabPanel("Waterpoints", DTOutput("water_table"))
      )
    )
  )
)

server <- function(input, output, session){
  # load seeds if no upload
  data_in <- reactiveVal()
  observeEvent(TRUE, {
    if(is.null(input$upload)){
      df <- readr::read_csv("data/outreach_masindi.csv", show_col_types=FALSE)
    } else {
      df <- readr::read_csv(input$upload$datapath, show_col_types=FALSE)
    }
    df <- clean_outreach(df)
    data_in(df)
    updateSelectInput(session, "facility", choices = c("All", sort(unique(df$facility))), selected="All")
  }, once=TRUE)
  
  filtered <- eventReactive(input$refresh, {
    df <- data_in()
    if(input$facility!="All") df <- df %>% filter(facility==input$facility)
    df
  }, ignoreNULL = FALSE)
  
  output$trend_plot <- renderPlotly({
    df <- filtered()
    recent <- df %>% filter(date >= Sys.Date() - as.numeric(input$period))
    monthly <- recent %>% mutate(month=floor_date(date,"month")) %>% group_by(month) %>% summarise(att=sum(attendance))
    p <- plot_ly(monthly, x=~month, y=~att, type="scatter", mode="lines+markers") %>% layout(title="Recent attendance trend")
    p
  })
  
  output$key_metrics <- renderDT({
    df <- filtered()
    recent <- df %>% filter(date >= Sys.Date() - as.numeric(input$period))
    metrics <- tibble(
      metric = c("Mean attendance (window)","Median attendance","Max day","Events"),
      value = c(round(mean(recent$attendance, na.rm=TRUE),1), median(recent$attendance, na.rm=TRUE), max(recent$attendance, na.rm=TRUE), nrow(recent))
    )
    datatable(metrics, options=list(dom='t'))
  })
  
  output$recommendation <- renderText({
    df <- filtered()
    recent <- df %>% filter(date >= Sys.Date() - as.numeric(input$period))
    decision_recommendation(recent)
  })
  
  output$anomaly_table <- renderDT({
    # simple z-score anomaly per facility
    df <- filtered()
    dfz <- df %>% group_by(facility) %>% mutate(z = (attendance - mean(attendance,na.rm=TRUE))/sd(attendance,na.rm=TRUE)) %>% ungroup()
    anom <- dfz %>% filter(abs(z) > 2) %>% arrange(desc(abs(z)))
    datatable(anom, options=list(pageLength=10))
  })
  
  output$water_table <- renderDT({
    w <- readr::read_csv("data/waterpoints_masindi.csv", show_col_types=FALSE)
    datatable(w, options=list(pageLength=10))
  })
}

shinyApp(ui, server)
