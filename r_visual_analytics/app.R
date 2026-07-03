# ============================================================
# Malaysia Financial Analytics Platform
# Professional Shiny Dashboard
# ============================================================

library(shiny)
library(shinydashboard)
library(tidyverse)
library(plotly)
library(scales)
library(DT)
library(broom)

# ============================================================
# 1. Load Data
# ============================================================

dashboard_df <- read_csv("data/final/analysis_dataset_dashboard.csv", show_col_types = FALSE)

indicator_order <- c(
  "GDP Growth",
  "Inflation",
  "Unemployment",
  "Income per Capita",
  "Household Consumption",
  "Gross Domestic Savings",
  "Lending Rate",
  "Deposit Rate",
  "Domestic Credit",
  "Non-performing Loans"
)

dashboard_df <- dashboard_df %>%
  mutate(
    Indicator = factor(Indicator, levels = indicator_order),
    Theme = case_when(
      Indicator %in% c("GDP Growth", "Inflation", "Unemployment", "Income per Capita") ~ "Economic Performance",
      Indicator %in% c("Household Consumption", "Gross Domestic Savings") ~ "Household Behaviour",
      TRUE ~ "Financial System"
    )
  )

# ============================================================
# 2. Theme Colours
# ============================================================

main_colour <- "#0B2545"
green_colour <- "#2E7D32"
brown_colour <- "#B36B00"
red_colour <- "#B22222"
grey_text <- "#4A4A4A"

theme_colours <- c(
  "Economic Performance" = main_colour,
  "Household Behaviour" = green_colour,
  "Financial System" = brown_colour
)

# ============================================================
# 3. Helper Functions
# ============================================================

format_value <- function(indicator, value) {
  if (indicator %in% c("Income per Capita", "Household Consumption")) {
    paste0("US$", comma(round(value, 0)))
  } else {
    paste0(sprintf("%.2f", value), "%")
  }
}

make_trend_plot <- function(data, indicator_name) {
  
  plot_data <- data %>%
    filter(Indicator == indicator_name) %>%
    arrange(Year)
  
  theme_name <- unique(plot_data$Theme)[1]
  line_colour <- theme_colours[[theme_name]]
  
  plot_ly(
    plot_data,
    x = ~Year,
    y = ~Value,
    type = "scatter",
    mode = "lines+markers",
    line = list(color = line_colour, width = 3),
    marker = list(size = 7, color = line_colour),
    hovertemplate = paste(
      "Year: %{x}<br>",
      "Value: %{y:.2f}<extra></extra>"
    )
  ) %>%
    layout(
      title = list(
        text = paste0("<b>", indicator_name, "</b>"),
        x = 0.02,
        font = list(size = 18, color = main_colour)
      ),
      xaxis = list(title = "Year", gridcolor = "#EAEAEA"),
      yaxis = list(title = "", gridcolor = "#EAEAEA"),
      plot_bgcolor = "white",
      paper_bgcolor = "white",
      margin = list(l = 60, r = 30, t = 70, b = 60)
    )
}

make_relationship_plot <- function(data, x_indicator, y_indicator) {
  
  wide_df <- data %>%
    select(Year, Indicator, Value) %>%
    pivot_wider(names_from = Indicator, values_from = Value) %>%
    select(Year, all_of(x_indicator), all_of(y_indicator)) %>%
    drop_na()
  
  r_value <- cor(wide_df[[x_indicator]], wide_df[[y_indicator]])
  model <- lm(wide_df[[y_indicator]] ~ wide_df[[x_indicator]])
  model_info <- glance(model)
  
  plot_ly(
    wide_df,
    x = wide_df[[x_indicator]],
    y = wide_df[[y_indicator]],
    text = ~paste("Year:", Year),
    type = "scatter",
    mode = "markers",
    marker = list(size = 9, color = main_colour, opacity = 0.8),
    hovertemplate = paste(
      "%{text}<br>",
      x_indicator, ": %{x:.2f}<br>",
      y_indicator, ": %{y:.2f}<extra></extra>"
    )
  ) %>%
    add_lines(
      x = wide_df[[x_indicator]],
      y = fitted(model),
      line = list(color = red_colour, width = 3),
      name = "Regression Line",
      hoverinfo = "skip"
    ) %>%
    layout(
      title = list(
        text = paste0(
          "<b>", x_indicator, " vs ", y_indicator, "</b>",
          "<br><sup>r = ", sprintf("%.2f", r_value),
          " | R² = ", sprintf("%.2f", model_info$r.squared), "</sup>"
        ),
        x = 0.02,
        font = list(size = 17, color = main_colour)
      ),
      xaxis = list(title = x_indicator, gridcolor = "#EAEAEA"),
      yaxis = list(title = y_indicator, gridcolor = "#EAEAEA"),
      plot_bgcolor = "white",
      paper_bgcolor = "white",
      margin = list(l = 70, r = 30, t = 90, b = 70)
    )
}

# ============================================================
# 4. Executive KPI Summary
# ============================================================

assessment_rules <- tibble(
  Indicator = indicator_order,
  Desired_Direction = c(
    "Higher", "Lower", "Lower", "Higher",
    "Higher", "Higher",
    "Lower", "Higher", "Higher", "Lower"
  )
)

kpi_summary <- dashboard_df %>%
  group_by(Indicator, Theme) %>%
  summarise(
    First_Year = min(Year),
    First_Value = Value[Year == min(Year)][1],
    Latest_Year = max(Year),
    Latest_Value = Value[Year == max(Year)][1],
    .groups = "drop"
  ) %>%
  left_join(assessment_rules, by = "Indicator") %>%
  mutate(
    Trend = case_when(
      Latest_Value > First_Value ~ "Increasing",
      Latest_Value < First_Value ~ "Decreasing",
      TRUE ~ "Stable"
    ),
    Assessment = case_when(
      Trend == "Increasing" & Desired_Direction == "Higher" ~ "Favourable",
      Trend == "Decreasing" & Desired_Direction == "Lower" ~ "Favourable",
      TRUE ~ "Less Favourable"
    ),
    Latest_Label = map2_chr(as.character(Indicator), Latest_Value, format_value),
    First_Label = map2_chr(as.character(Indicator), First_Value, format_value)
  )

# ============================================================
# 5. User Interface
# ============================================================

ui <- dashboardPage(
  
  dashboardHeader(
    title = span("Malaysia Financial Analytics Platform")
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Executive Overview", tabName = "overview", icon = icon("chart-line")),
      menuItem("Indicator Explorer", tabName = "indicator", icon = icon("magnifying-glass-chart")),
      menuItem("Relationship Explorer", tabName = "relationship", icon = icon("project-diagram")),
      menuItem("Data Table", tabName = "data", icon = icon("table"))
    )
  ),
  
  dashboardBody(
    
    tags$head(
      tags$style(HTML("
        .skin-blue .main-header .logo {
          background-color: #0B2545;
          font-weight: bold;
        }
        .skin-blue .main-header .navbar {
          background-color: #0B2545;
        }
        .skin-blue .main-sidebar {
          background-color: #0B2545;
        }
        .content-wrapper, .right-side {
          background-color: #F7F9FB;
        }
        .box {
          border-radius: 8px;
          border-top: 3px solid #0B2545;
          box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }
        .small-box {
          border-radius: 8px;
        }
        h2, h3, h4 {
          color: #0B2545;
          font-weight: 700;
        }
      "))
    ),
    
    tabItems(
      
      # ======================================================
      # Executive Overview
      # ======================================================
      
      tabItem(
        tabName = "overview",
        
        fluidRow(
          box(
            width = 12,
            title = "Executive Economic Assessment",
            status = "primary",
            solidHeader = TRUE,
            h3("Malaysia's Economic, Household and Financial Conditions"),
            p("This dashboard integrates selected World Bank indicators to provide an executive-level view of Malaysia's economic performance, household behaviour and financial system stability from 2000 to 2024.")
          )
        ),
        
        fluidRow(
          valueBox(
            value = nrow(kpi_summary %>% filter(Assessment == "Favourable")),
            subtitle = "Favourable Indicators",
            color = "green",
            icon = icon("check-circle")
          ),
          valueBox(
            value = nrow(kpi_summary %>% filter(Assessment == "Less Favourable")),
            subtitle = "Less Favourable Indicators",
            color = "red",
            icon = icon("exclamation-triangle")
          ),
          valueBox(
            value = paste0(min(dashboard_df$Year), "–", max(dashboard_df$Year)),
            subtitle = "Study Period",
            color = "blue",
            icon = icon("calendar")
          )
        ),
        
        fluidRow(
          box(
            width = 12,
            title = "Latest Indicator Assessment",
            status = "primary",
            solidHeader = TRUE,
            DTOutput("kpi_table")
          )
        )
      ),
      
      # ======================================================
      # Indicator Explorer
      # ======================================================
      
      tabItem(
        tabName = "indicator",
        
        fluidRow(
          box(
            width = 3,
            title = "Controls",
            status = "primary",
            solidHeader = TRUE,
            selectInput(
              "selected_indicator",
              "Select Indicator",
              choices = levels(dashboard_df$Indicator),
              selected = "GDP Growth"
            ),
            sliderInput(
              "year_range",
              "Year Range",
              min = min(dashboard_df$Year),
              max = max(dashboard_df$Year),
              value = c(min(dashboard_df$Year), max(dashboard_df$Year)),
              sep = ""
            )
          ),
          
          box(
            width = 9,
            title = "Indicator Trend",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("indicator_plot", height = "520px")
          )
        )
      ),
      
      # ======================================================
      # Relationship Explorer
      # ======================================================
      
      tabItem(
        tabName = "relationship",
        
        fluidRow(
          box(
            width = 3,
            title = "Relationship Controls",
            status = "primary",
            solidHeader = TRUE,
            selectInput(
              "x_indicator",
              "X-axis Indicator",
              choices = levels(dashboard_df$Indicator),
              selected = "Income per Capita"
            ),
            selectInput(
              "y_indicator",
              "Y-axis Indicator",
              choices = levels(dashboard_df$Indicator),
              selected = "Household Consumption"
            )
          ),
          
          box(
            width = 9,
            title = "Relationship Analysis",
            status = "primary",
            solidHeader = TRUE,
            plotlyOutput("relationship_plot", height = "520px")
          )
        )
      ),
      
      # ======================================================
      # Data Table
      # ======================================================
      
      tabItem(
        tabName = "data",
        
        fluidRow(
          box(
            width = 12,
            title = "Processed Indicator Dataset",
            status = "primary",
            solidHeader = TRUE,
            DTOutput("data_table")
          )
        )
      )
    )
  )
)

# ============================================================
# 6. Server
# ============================================================

server <- function(input, output, session) {
  
  output$kpi_table <- renderDT({
    kpi_summary %>%
      select(
        Indicator,
        Theme,
        First_Year,
        First_Label,
        Latest_Year,
        Latest_Label,
        Trend,
        Assessment
      ) %>%
      datatable(
        rownames = FALSE,
        options = list(pageLength = 10, dom = "tip"),
        colnames = c(
          "Indicator",
          "Theme",
          "First Year",
          "First Value",
          "Latest Year",
          "Latest Value",
          "Trend",
          "Assessment"
        )
      )
  })
  
  output$indicator_plot <- renderPlotly({
    
    filtered_df <- dashboard_df %>%
      filter(
        Indicator == input$selected_indicator,
        Year >= input$year_range[1],
        Year <= input$year_range[2]
      )
    
    make_trend_plot(filtered_df, input$selected_indicator)
  })
  
  output$relationship_plot <- renderPlotly({
    
    validate(
      need(
        input$x_indicator != input$y_indicator,
        "Please select two different indicators."
      )
    )
    
    make_relationship_plot(
      dashboard_df,
      input$x_indicator,
      input$y_indicator
    )
  })
  
  output$data_table <- renderDT({
    dashboard_df %>%
      arrange(Indicator, Year) %>%
      datatable(
        rownames = FALSE,
        filter = "top",
        options = list(pageLength = 15, scrollX = TRUE)
      )
  })
}

# ============================================================
# 7. Run App
# ============================================================

shinyApp(ui = ui, server = server)
