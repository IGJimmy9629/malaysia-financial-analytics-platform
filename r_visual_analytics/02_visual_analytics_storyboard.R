# ============================================================
# Malaysia Financial Performance Analytics Platform
# Visual Analytics Storyboard
# Study Period: 2000–2024
# ============================================================

# ============================================================
# 1. Load Required Libraries
# ============================================================

library(tidyverse)
library(readr)
library(ggplot2)
library(scales)
library(plotly)
library(htmlwidgets)

# ============================================================
# 2. Load ETL Output Datasets
# ============================================================

dashboard_df <- read_csv("data/final/analysis_dataset_dashboard.csv")
heatmap_df <- read_csv("data/final/analysis_dataset_heatmap.csv")
kpi_df <- read_csv("data/final/executive_kpi_summary.csv")
indicator_catalog <- read_csv("data/metadata/indicator_catalog.csv")
project_metadata <- read_csv("data/metadata/project_metadata.csv")
indicator_summary <- read_csv("data/metadata/indicator_summary.csv")
theme_summary <- read_csv("data/metadata/theme_summary.csv")

# ============================================================
# Verify ETL Output
# ============================================================

glimpse(dashboard_df)

unique(dashboard_df$Indicator)

unique(dashboard_df$Theme)

range(dashboard_df$Year)

colSums(is.na(dashboard_df))

table(dashboard_df$Indicator)

# ============================================================
# 3. Validate Imported Data
# ============================================================

nrow(dashboard_df)
ncol(dashboard_df)
colSums(is.na(dashboard_df))
sum(duplicated(dashboard_df))
unique(dashboard_df$Indicator)
unique(dashboard_df$Theme)
range(dashboard_df$Year)

glimpse(dashboard_df)
glimpse(kpi_df)

# ============================================================
# 4. Storyboard Configuration
# ============================================================

theme_set(theme_minimal())

main_colour <- "#0B2545"
secondary_colour <- "#6C757D"
highlight_colour <- "#D62728"
area_colour <- "#BFD7ED"
grid_colour <- "grey88"

theme_corporate <- function() {
  theme_minimal() +
    theme(
      legend.position = "top",
      plot.title = element_text(size = 20, face = "bold", colour = main_colour),
      plot.subtitle = element_text(size = 12, colour = "grey20"),
      axis.title = element_text(size = 11),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = grid_colour),
      plot.caption = element_text(size = 9, colour = "grey40")
    )
}

# ============================================================
# 5. Prepare Data for Visualisation
# ============================================================

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

dashboard_df$Indicator <- factor(
  dashboard_df$Indicator,
  levels = indicator_order
)

# Do NOT factor heatmap_df$Indicator because heatmap_df is already wide format
# and does not contain an Indicator column.

# Confirm no indicator became NA after factor ordering
unique(dashboard_df$Indicator)
sum(is.na(dashboard_df$Indicator))
table(dashboard_df$Indicator)

# Optional check for heatmap wide dataset
names(heatmap_df)
dim(heatmap_df)

# ============================================================
# 6. Prepare Visual Output Folders
# ============================================================

dir.create("visuals/storyboard", recursive = TRUE, showWarnings = FALSE)
dir.create("visuals/interactive", recursive = TRUE, showWarnings = FALSE)
dir.create("visuals/animation", recursive = TRUE, showWarnings = FALSE)
dir.create("visuals/archive_2018_2024", recursive = TRUE, showWarnings = FALSE)

print("Visual output folders ready.")

# ============================================================
# 7. Malaysia's Economic Journey Animation
# ============================================================

# Business Question:
# What does Malaysia's economic journey reveal over the past twenty-five years?

# Analytical Purpose:
# To provide an animated overview of Malaysia's economic journey
# using GDP growth as the opening indicator before examining
# household, financial and banking indicators in greater detail.

# Output:
# Frame 02 – Malaysia's Economic Journey Animation

library(gganimate)
library(gifski)

gdp_animation_df <- dashboard_df %>%
  filter(Indicator == "GDP Growth") %>%
  mutate(
    Point_Type = case_when(
      Year %in% c(2009, 2020) ~ "Contraction",
      Year %in% c(2021, 2022) ~ "Recovery",
      TRUE ~ "Normal Growth"
    ),
    Event_Label = case_when(
      Year == 2001 ~ "Early 2000s adjustment",
      Year == 2009 ~ "Global Financial Crisis",
      Year == 2020 ~ "COVID-19 contraction",
      Year == 2022 ~ "Strong post-pandemic rebound",
      TRUE ~ "Long-term economic movement"
    )
  )

p_gdp_animation <- ggplot(gdp_animation_df, aes(x = Year, y = Value)) +
  
  # Highlight major downturn periods
  annotate(
    "rect",
    xmin = 2008,
    xmax = 2009,
    ymin = -8,
    ymax = 11,
    fill = "#FDECEC",
    alpha = 0.35
  ) +
  annotate(
    "rect",
    xmin = 2020,
    xmax = 2021,
    ymin = -8,
    ymax = 11,
    fill = "#FDECEC",
    alpha = 0.35
  ) +
  
  # Zero reference line
  geom_hline(
    yintercept = 0,
    colour = "grey50",
    linewidth = 0.6
  ) +
  
  # Animated trend
  geom_line(
    colour = main_colour,
    linewidth = 1.35
  ) +
  geom_point(
    aes(colour = Point_Type),
    size = 3.2
  ) +
  
  # Moving focus point
  geom_point(
    aes(group = seq_along(Year)),
    colour = highlight_colour,
    size = 5
  ) +
  
  # Dynamic annotation box
  geom_label(
    aes(
      x = 2003,
      y = 9.5,
      label = paste0(
        "Current Year: ", Year,
        "\nGDP Growth: ", sprintf("%.2f%%", Value),
        "\nContext: ", Event_Label
      )
    ),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 4,
    fontface = "bold",
    label.padding = unit(0.35, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25
  ) +
  
  scale_colour_manual(
    values = c(
      "Normal Growth" = main_colour,
      "Contraction" = highlight_colour,
      "Recovery" = "#1F77B4"
    )
  ) +
  
  scale_x_continuous(
    breaks = seq(2000, 2024, by = 4)
  ) +
  scale_y_continuous(
    limits = c(-8, 11),
    breaks = seq(-8, 10, by = 2),
    labels = function(x) paste0(x, "%")
  ) +
  
  labs(
    title = "Malaysia's Economic Journey",
    subtitle = "Animated overview of Malaysia's economic journey, 2000–2024",
    x = "Year",
    y = "GDP Growth (%)",
    caption = "Source: World Bank Open Data | Note: GDP growth is used as the opening indicator of Malaysia's broader economic journey."
  ) +
  
  theme_corporate() +
  theme(
    legend.position = "none"
  ) +
  
  transition_reveal(Year) +
  shadow_mark(
    alpha = 0.25,
    size = 1.2
  ) +
  ease_aes("linear")

animate(
  p_gdp_animation,
  nframes = 180,
  fps = 12,
  width = 1000,
  height = 600,
  renderer = gifski_renderer(
    "visuals/animation/frame_02_malaysia_economic_journey_2000_2024.gif"
  )
)

# ============================================================
# 8. Malaysia GDP Growth Performance
# ============================================================

# Business Question:
# How did Malaysia's GDP growth respond to major economic events between 2000 and 2024?

# Analytical Purpose:
# To identify periods of economic expansion, recession and recovery,
# including the Global Financial Crisis and COVID-19 pandemic.

# Output:
# Frame 03 – Malaysia GDP Growth Performance

gdp_df <- dashboard_df %>%
  filter(Indicator == "GDP Growth") %>%
  mutate(
    Point_Type = case_when(
      Year %in% c(2009, 2020) ~ "Contraction",
      Year %in% c(2001, 2021, 2022) ~ "Turning Point / Recovery",
      TRUE ~ "Normal Growth"
    )
  )

gdp_label_df <- gdp_df %>%
  filter(Year == max(Year))

gdp_event_labels <- tibble(
  Event_Year = c(2001, 2008, 2009, 2019, 2020, 2021, 2022),
  Label_X = c(2001.8, 2007.1, 2010.2, 2018.4, 2020.8, 2021.8, 2022.9),
  Label_Y = c(-2.7, 1.4, -4.8, 8.8, -7.2, -2.3, 10.4),
  Event_Text = c(
    "Early 2000s slowdown",
    "Before GFC",
    "GFC impact",
    "Before COVID-19",
    "COVID-19 contraction",
    "After contraction",
    "Strong rebound"
  ),
  Label_Colour = c(
    "#6C757D",
    highlight_colour,
    highlight_colour,
    highlight_colour,
    highlight_colour,
    "#1F77B4",
    "#1F77B4"
  )
) %>%
  left_join(
    gdp_df %>% select(Event_Year = Year, Event_Value = Value),
    by = "Event_Year"
  ) %>%
  mutate(
    Label = paste0(Event_Text, "\n", Event_Year, ": ", sprintf("%.2f%%", Event_Value))
  )

p_gdp <- ggplot(gdp_df, aes(x = Year, y = Value)) +
  annotate("rect", xmin = 2008, xmax = 2009, ymin = -8, ymax = 11,
           fill = "#FDECEC", alpha = 0.35) +
  annotate("rect", xmin = 2020, xmax = 2021, ymin = -8, ymax = 11,
           fill = "#FDECEC", alpha = 0.35) +
  geom_hline(yintercept = 0, colour = "grey50", linewidth = 0.6) +
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(aes(colour = Point_Type), size = 3.3) +
  geom_text(
    data = gdp_label_df,
    aes(label = sprintf("%.2f%%", Value)),
    vjust = -1,
    size = 3.5,
    fontface = "bold",
    colour = main_colour
  ) +
  geom_segment(
    data = gdp_event_labels,
    aes(x = Event_Year, xend = Label_X, y = Event_Value, yend = Label_Y),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.45
  ) +
  geom_label(
    data = gdp_event_labels,
    aes(x = Label_X, y = Label_Y, label = Label, colour = Label_Colour),
    inherit.aes = FALSE,
    fill = "white",
    size = 3.3,
    fontface = "bold",
    label.padding = unit(0.25, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25,
    show.legend = FALSE
  ) +
  scale_colour_manual(
    values = c(
      "Normal Growth" = main_colour,
      "Contraction" = highlight_colour,
      "Turning Point / Recovery" = "#1F77B4",
      "#6C757D" = "#6C757D",
      "#D62728" = "#D62728",
      "#1F77B4" = "#1F77B4"
    )
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +
  scale_y_continuous(limits = c(-8, 11), breaks = seq(-8, 10, by = 2)) +
  labs(
    title = "Malaysia GDP Growth Performance",
    subtitle = "Annual GDP growth rate, 2000–2024",
    x = "Year",
    y = "GDP Growth (%)",
    caption = "Source: World Bank Open Data | Note: Figures are annual percentage change (%)"
  ) +
  theme_corporate() +
  theme(legend.position = "none")

p_gdp

ggsave(
  "visuals/storyboard/frame_03_malaysia_gdp_growth_performance_2000_2024.png",
  p_gdp,
  width = 12,
  height = 7,
  dpi = 300
)

# ============================================================
# 9. Malaysia Inflation Performance
# ============================================================

# Business Question:
# How has Malaysia's inflation rate changed over the last twenty-five years?

# Analytical Purpose:
# To examine long-term price stability and identify periods of unusually
# high or low inflation.

# Output:
# Frame 04 – Malaysia Inflation Performance

inflation_df <- dashboard_df %>%
  filter(Indicator == "Inflation") %>%
  mutate(
    Point_Type = case_when(
      Value < 0 ~ "Deflation / Low Pressure",
      Value >= 4 ~ "High Inflation Pressure",
      TRUE ~ "Normal Inflation"
    )
  )

# Latest year direct label
inflation_label_df <- inflation_df %>%
  filter(Year == max(Year))

# Event labels are generated from actual data values
inflation_event_labels <- tibble(
  Event_Year = c(
    inflation_df$Year[which.min(inflation_df$Value)],
    inflation_df$Year[which.max(inflation_df$Value)],
    max(inflation_df$Year)
  ),
  Label_X = c(2009.5, 2008.5, 2022.8),
  Label_Y = c(-2.2, 6.2, 4.6),
  Event_Text = c(
    "Lowest inflation point",
    "Highest inflation pressure",
    "Latest available value"
  ),
  Label_Colour = c(
    "#1F77B4",
    highlight_colour,
    main_colour
  )
) %>%
  left_join(
    inflation_df %>% select(Event_Year = Year, Event_Value = Value),
    by = "Event_Year"
  ) %>%
  mutate(
    Label = paste0(
      Event_Text,
      "\n",
      Event_Year,
      ": ",
      sprintf("%.2f%%", Event_Value)
    )
  )

# Create Visualisation
p_inflation <- ggplot(inflation_df, aes(x = Year, y = Value)) +
  
  # Light background emphasis for global crisis and post-pandemic inflation period
  annotate("rect", xmin = 2008, xmax = 2009, ymin = -3, ymax = 7,
           fill = "#FDECEC", alpha = 0.30) +
  annotate("rect", xmin = 2021, xmax = 2022, ymin = -3, ymax = 7,
           fill = "#FDECEC", alpha = 0.30) +
  
  # Zero reference line
  geom_hline(yintercept = 0, colour = "grey50", linewidth = 0.6) +
  
  # Area and line
  geom_area(fill = area_colour, alpha = 0.55) +
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(aes(colour = Point_Type), size = 3.2) +
  
  # Direct label for latest value
  geom_text(
    data = inflation_label_df,
    aes(label = sprintf("%.2f%%", Value)),
    vjust = -1,
    size = 3.5,
    fontface = "bold",
    colour = main_colour
  ) +
  
  # Leader lines
  geom_segment(
    data = inflation_event_labels,
    aes(x = Event_Year, xend = Label_X, y = Event_Value, yend = Label_Y),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.45
  ) +
  
  # Event callout boxes
  geom_label(
    data = inflation_event_labels,
    aes(x = Label_X, y = Label_Y, label = Label, colour = Label_Colour),
    inherit.aes = FALSE,
    fill = "white",
    size = 3.3,
    fontface = "bold",
    label.padding = unit(0.25, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25,
    show.legend = FALSE
  ) +
  
  scale_colour_manual(
    values = c(
      "Normal Inflation" = main_colour,
      "High Inflation Pressure" = highlight_colour,
      "Deflation / Low Pressure" = "#1F77B4",
      "#D62728" = "#D62728",
      "#1F77B4" = "#1F77B4",
      "#0B2545" = main_colour
    )
  ) +
  scale_x_continuous(
    breaks = seq(2000, 2024, by = 4)
  ) +
  scale_y_continuous(
    limits = c(-3, 7),
    breaks = seq(-2, 6, by = 2)
  ) +
  labs(
    title = "Malaysia Inflation Performance",
    subtitle = "Consumer price inflation rate, 2000–2024",
    x = "Year",
    y = "Inflation (%)",
    caption = "Source: World Bank Open Data | Note: Figures are annual percentage change (%)"
  ) +
  theme_corporate() +
  theme(
    legend.position = "none"
  )

p_inflation

ggsave(
  "visuals/storyboard/frame_04_malaysia_inflation_performance_2000_2024.png",
  p_inflation,
  width = 12,
  height = 7,
  dpi = 300
)

# ============================================================
# 10. Malaysia Unemployment Performance
# ============================================================

# Business Question:
# How resilient has Malaysia's labour market been between 2000 and 2024?

# Analytical Purpose:
# To evaluate labour market performance during economic shocks
# and subsequent recovery periods.

# Output:
# Frame 05 – Malaysia Unemployment Performance

unemployment_df <- dashboard_df %>%
  filter(Indicator == "Unemployment") %>%
  mutate(
    Point_Type = case_when(
      Value == max(Value) ~ "Highest Unemployment",
      Value == min(Value) ~ "Lowest Unemployment",
      TRUE ~ "Normal Movement"
    )
  )

unemployment_label_df <- unemployment_df %>%
  filter(Year == max(Year))

unemployment_event_labels <- tibble(
  Event_Year = c(
    unemployment_df$Year[which.min(unemployment_df$Value)],
    unemployment_df$Year[which.max(unemployment_df$Value)],
    max(unemployment_df$Year)
  ),
  Label_X = c(2005.5, 2020.8, 2022.8),
  Label_Y = c(2.8, 5.2, 3.0),
  Event_Text = c(
    "Lowest unemployment",
    "Highest unemployment",
    "Latest available value"
  ),
  Label_Colour = c(
    "#1F77B4",
    highlight_colour,
    main_colour
  )
) %>%
  left_join(
    unemployment_df %>% select(Event_Year = Year, Event_Value = Value),
    by = "Event_Year"
  ) %>%
  mutate(
    Label = paste0(
      Event_Text,
      "\n",
      Event_Year,
      ": ",
      sprintf("%.2f%%", Event_Value)
    )
  )

p_unemployment <- ggplot(unemployment_df, aes(x = Year, y = Value)) +
  annotate("rect", xmin = 2020, xmax = 2021, ymin = 2.5, ymax = 5.5,
           fill = "#FDECEC", alpha = 0.30) +
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(aes(colour = Point_Type), size = 3.2) +
  geom_text(
    data = unemployment_label_df,
    aes(label = sprintf("%.2f%%", Value)),
    vjust = -1,
    size = 3.5,
    fontface = "bold",
    colour = main_colour
  ) +
  geom_segment(
    data = unemployment_event_labels,
    aes(x = Event_Year, xend = Label_X, y = Event_Value, yend = Label_Y),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.45
  ) +
  geom_label(
    data = unemployment_event_labels,
    aes(x = Label_X, y = Label_Y, label = Label, colour = Label_Colour),
    inherit.aes = FALSE,
    fill = "white",
    size = 3.3,
    fontface = "bold",
    label.padding = unit(0.25, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25,
    show.legend = FALSE
  ) +
  scale_colour_manual(
    values = c(
      "Normal Movement" = main_colour,
      "Highest Unemployment" = highlight_colour,
      "Lowest Unemployment" = "#1F77B4",
      "#D62728" = "#D62728",
      "#1F77B4" = "#1F77B4",
      "#0B2545" = main_colour
    )
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +
  scale_y_continuous(limits = c(2.5, 5.5), breaks = seq(2.5, 5.5, 0.5)) +
  labs(
    title = "Malaysia Unemployment Performance",
    subtitle = "Unemployment rate, 2000–2024",
    x = "Year",
    y = "Unemployment Rate (%)",
    caption = "Source: World Bank Open Data | Note: Figures are percentage of total labour force"
  ) +
  theme_corporate() +
  theme(legend.position = "none")

p_unemployment

ggsave(
  "visuals/storyboard/frame_05_malaysia_unemployment_performance_2000_2024.png",
  p_unemployment,
  width = 12,
  height = 7,
  dpi = 300
)

# ============================================================
# 11. Malaysia Household Income Growth
# ============================================================

# Business Question:
# How has household income changed over time?

# Analytical Purpose:
# To examine improvements in household purchasing power
# and long-term income growth.

# Output:
# Frame 06 – Malaysia Household Income Growth

income_df <- dashboard_df %>%
  filter(Indicator == "Income per Capita") %>%
  mutate(
    Point_Type = case_when(
      Value == max(Value) ~ "Highest Income",
      Value == min(Value) ~ "Lowest Income",
      Year == max(Year) ~ "Latest Value",
      TRUE ~ "Normal Movement"
    )
  )

income_summary <- income_df %>%
  summarise(
    min_year = Year[which.min(Value)],
    min_value = min(Value),
    max_year = Year[which.max(Value)],
    max_value = max(Value),
    latest_year = max(Year),
    latest_value = Value[Year == max(Year)]
  )

income_event_labels <- tibble(
  Event_Year = c(
    income_summary$min_year,
    income_summary$max_year,
    income_summary$latest_year
  ),
  Label_X = c(
    income_summary$min_year + 1.7,
    income_summary$max_year - 2.5,
    income_summary$latest_year - 2.4
  ),
  Label_Y = c(
    income_summary$min_value * 1.08,
    income_summary$max_value * 1.04,
    income_summary$latest_value * 0.95
  ),
  Event_Text = c(
    "Lowest income level",
    "Highest income level",
    "Latest available value"
  )
) %>%
  left_join(
    income_df %>% select(Event_Year = Year, Event_Value = Value),
    by = "Event_Year"
  ) %>%
  mutate(
    Label = paste0(
      Event_Text,
      "\n",
      Event_Year,
      ": US$",
      scales::comma(round(Event_Value, 0))
    )
  )

p_income <- ggplot(income_df, aes(x = Year, y = Value)) +
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(aes(colour = Point_Type), size = 3.2) +
  geom_segment(
    data = income_event_labels,
    aes(x = Event_Year, xend = Label_X, y = Event_Value, yend = Label_Y),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.45
  ) +
  geom_label(
    data = income_event_labels,
    aes(x = Label_X, y = Label_Y, label = Label),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 3.3,
    fontface = "bold",
    label.padding = unit(0.25, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25
  ) +
  scale_colour_manual(
    values = c(
      "Normal Movement" = main_colour,
      "Highest Income" = "#1F77B4",
      "Lowest Income" = highlight_colour,
      "Latest Value" = main_colour
    )
  ) +
  scale_x_continuous(breaks = seq(min(income_df$Year), max(income_df$Year), by = 4)) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "US$", accuracy = 1)) +
  labs(
    title = "Malaysia Household Income Growth",
    subtitle = "Adjusted net national income per capita, constant 2015 US$, 2000–2021",
    x = "Year",
    y = "Income per Capita",
    caption = "Source: World Bank Open Data | Note: Latest available value ends in 2021"
  ) +
  theme_corporate() +
  theme(legend.position = "none")

p_income

ggsave(
  "visuals/storyboard/frame_06_household_income_growth_2000_2021.png",
  p_income,
  width = 12,
  height = 7,
  dpi = 300
)

# ============================================================
# 12. Malaysia Household Financial Behaviour
# ============================================================

# Business Question:
# How have Malaysian households balanced consumption and savings over time?

# Analytical Purpose:
# To compare household spending behaviour with national saving capacity
# across different economic conditions.

# Output:
# Frame 07 – Malaysia Household Financial Behaviour

library(patchwork)

# ------------------------------------------------------------
# 12.1 Prepare Datasets
# ------------------------------------------------------------

consumption_df <- dashboard_df %>%
  filter(Indicator == "Household Consumption") %>%
  arrange(Year)

saving_df <- dashboard_df %>%
  filter(Indicator == "Gross Domestic Savings") %>%
  arrange(Year)

# ------------------------------------------------------------
# 12.2 Prepare Start and Latest Points Only
# ------------------------------------------------------------

consumption_key <- bind_rows(
  consumption_df %>%
    filter(Year == min(Year)) %>%
    mutate(Point_Type = "Initial"),
  consumption_df %>%
    filter(Year == max(Year)) %>%
    mutate(Point_Type = "Latest")
) %>%
  mutate(
    Label = paste0(
      Point_Type,
      "\n",
      Year,
      ": US$",
      scales::comma(round(Value, 0))
    ),
    Label_X = case_when(
      Point_Type == "Initial" ~ Year + 1.3,
      Point_Type == "Latest" ~ Year - 1.6,
      TRUE ~ Year
    ),
    Label_Y = case_when(
      Point_Type == "Initial" ~ Value + 400,
      Point_Type == "Latest" ~ Value + 400,
      TRUE ~ Value
    )
  )

saving_key <- bind_rows(
  saving_df %>%
    filter(Year == min(Year)) %>%
    mutate(Point_Type = "Initial"),
  saving_df %>%
    filter(Year == max(Year)) %>%
    mutate(Point_Type = "Latest")
) %>%
  mutate(
    Label = paste0(
      Point_Type,
      "\n",
      Year,
      ": ",
      sprintf("%.2f%%", Value)
    ),
    Label_X = case_when(
      Point_Type == "Initial" ~ Year + 1.3,
      Point_Type == "Latest" ~ Year - 1.6,
      TRUE ~ Year
    ),
    Label_Y = case_when(
      Point_Type == "Initial" ~ Value + 3.0,
      Point_Type == "Latest" ~ Value + 3.0,
      TRUE ~ Value
    )
  )

# ------------------------------------------------------------
# 12.3 Calculate Overall Changes
# ------------------------------------------------------------

consumption_change <- (
  (last(consumption_df$Value) - first(consumption_df$Value)) /
    first(consumption_df$Value)
) * 100

# Savings is already % of GDP, so show difference as percentage value
saving_change <- last(saving_df$Value) - first(saving_df$Value)

comparison_text <- paste0(
  "Consumption: ",
  ifelse(consumption_change >= 0, "+", ""),
  sprintf("%.1f%%", consumption_change),
  "   |   Savings: ",
  ifelse(saving_change >= 0, "+", ""),
  sprintf("%.2f%%", saving_change)
)

# ------------------------------------------------------------
# 12.4 Household Consumption Chart
# ------------------------------------------------------------

p_consumption <- ggplot(consumption_df, aes(x = Year, y = Value)) +
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(colour = main_colour, size = 2.5) +
  geom_point(
    data = consumption_key,
    aes(x = Year, y = Value),
    colour = highlight_colour,
    size = 3.8
  ) +
  geom_segment(
    data = consumption_key,
    aes(
      x = Year,
      xend = Label_X,
      y = Value,
      yend = Label_Y
    ),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.4
  ) +
  geom_label(
    data = consumption_key,
    aes(x = Label_X, y = Label_Y, label = Label),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 3.0,
    fontface = "bold",
    label.padding = unit(0.22, "lines"),
    label.r = unit(0.12, "lines"),
    linewidth = 0.25
  ) +
  annotate(
    "label",
    x = 2016.5,
    y = max(consumption_df$Value, na.rm = TRUE) * 0.82,
    label = paste0(
      "Overall Change\n",
      ifelse(consumption_change >= 0, "+", ""),
      sprintf("%.1f%%", consumption_change)
    ),
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.1,
    linewidth = 0.25
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +
  scale_y_continuous(labels = scales::dollar_format(prefix = "US$", accuracy = 1)) +
  labs(
    title = "Household Consumption",
    subtitle = "Household spending per capita, constant 2015 US$",
    x = NULL,
    y = "Constant 2015 US$"
  ) +
  theme_corporate() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 15, face = "bold", colour = main_colour),
    plot.subtitle = element_text(size = 10, colour = "grey20")
  )

# ------------------------------------------------------------
# 12.5 Gross Domestic Savings Chart
# ------------------------------------------------------------

p_saving <- ggplot(saving_df, aes(x = Year, y = Value)) +
  geom_line(colour = "#2E7D32", linewidth = 1.35) +
  geom_point(colour = "#2E7D32", size = 2.5) +
  geom_point(
    data = saving_key,
    aes(x = Year, y = Value),
    colour = highlight_colour,
    size = 3.8
  ) +
  geom_segment(
    data = saving_key,
    aes(
      x = Year,
      xend = Label_X,
      y = Value,
      yend = Label_Y
    ),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.4
  ) +
  geom_label(
    data = saving_key,
    aes(x = Label_X, y = Label_Y, label = Label),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 3.0,
    fontface = "bold",
    label.padding = unit(0.22, "lines"),
    label.r = unit(0.12, "lines"),
    linewidth = 0.25
  ) +
  annotate(
    "label",
    x = 2016.5,
    y = max(saving_df$Value, na.rm = TRUE) * 0.88,
    label = paste0(
      "Change\n",
      ifelse(saving_change >= 0, "+", ""),
      sprintf("%.2f%%", saving_change)
    ),
    fill = "white",
    colour = "#2E7D32",
    fontface = "bold",
    size = 3.1,
    linewidth = 0.25
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Gross Domestic Savings",
    subtitle = "Savings as percentage of GDP",
    x = NULL,
    y = "% of GDP"
  ) +
  theme_corporate() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 15, face = "bold", colour = "#2E7D32"),
    plot.subtitle = element_text(size = 10, colour = "grey20")
  )

# ------------------------------------------------------------
# 12.6 Combine Charts into Executive Panel
# ------------------------------------------------------------

p_household <- (p_consumption | p_saving) +
  plot_annotation(
    title = "Malaysia Household Financial Behaviour (2000–2024)",
    subtitle = paste0(
      "Household spending increased over time, while savings fluctuated across economic cycles.  ",
      comparison_text
    ),
    caption = "Source: World Bank Open Data | Indicators: Household Consumption per Capita (constant 2015 US$) and Gross Domestic Savings (% of GDP)",
    theme = theme(
      plot.title = element_text(
        size = 20,
        face = "bold",
        colour = main_colour,
        hjust = 0.5
      ),
      plot.subtitle = element_text(
        size = 11,
        colour = "grey20",
        hjust = 0.5
      ),
      plot.caption = element_text(
        size = 9,
        colour = "grey40"
      )
    )
  )

p_household

ggsave(
  "visuals/storyboard/frame_07_household_financial_behaviour_2000_2024.png",
  p_household,
  width = 15,
  height = 8,
  dpi = 300
)

# ============================================================
# 13. Malaysia Borrowing and Saving Environment
# ============================================================

# Business Question:
# Did Malaysia's financial environment encourage borrowing while
# maintaining reasonable returns for savers?

# Analytical Purpose:
# To compare lending and deposit rates and evaluate changes
# in household and business financing conditions.

# Output:
# Frame 08 – Malaysia Borrowing and Saving Environment

library(plotly)
library(htmlwidgets)

interest_df <- dashboard_df %>%
  filter(Indicator %in% c("Lending Rate", "Deposit Rate")) %>%
  arrange(Indicator, Year)

interest_wide <- interest_df %>%
  select(Year, Indicator, Value) %>%
  pivot_wider(names_from = Indicator, values_from = Value)

get_interest_points <- function(data, indicator_name) {
  
  temp <- data %>%
    filter(Indicator == indicator_name)
  
  bind_rows(
    temp %>% filter(Year == min(Year)) %>% mutate(Point_Type = "Initial"),
    temp %>% filter(Year == max(Year)) %>% mutate(Point_Type = "Latest"),
    temp %>% filter(Value == max(Value)) %>% slice(1) %>% mutate(Point_Type = "Highest"),
    temp %>% filter(Value == min(Value)) %>% slice(1) %>% mutate(Point_Type = "Lowest")
  ) %>%
    distinct(Indicator, Year, .keep_all = TRUE)
}

interest_key <- bind_rows(
  get_interest_points(interest_df, "Lending Rate"),
  get_interest_points(interest_df, "Deposit Rate")
) %>%
  mutate(
    Label = paste0(
      Indicator,
      "\n",
      Point_Type,
      "\n",
      Year,
      ": ",
      sprintf("%.2f%%", Value)
    ),
    Label_X = case_when(
      Indicator == "Lending Rate" & Point_Type == "Initial" ~ Year + 1.4,
      Indicator == "Lending Rate" & Point_Type == "Latest" ~ Year - 1.5,
      Indicator == "Lending Rate" & Point_Type == "Highest" ~ Year + 1.2,
      Indicator == "Lending Rate" & Point_Type == "Lowest" ~ Year - 1.5,
      
      Indicator == "Deposit Rate" & Point_Type == "Initial" ~ Year + 1.4,
      Indicator == "Deposit Rate" & Point_Type == "Latest" ~ Year - 1.5,
      Indicator == "Deposit Rate" & Point_Type == "Highest" ~ Year + 1.2,
      Indicator == "Deposit Rate" & Point_Type == "Lowest" ~ Year - 1.5,
      
      TRUE ~ Year
    ),
    Label_Y = case_when(
      Indicator == "Lending Rate" & Point_Type == "Initial" ~ Value + 0.75,
      Indicator == "Lending Rate" & Point_Type == "Latest" ~ Value + 0.75,
      Indicator == "Lending Rate" & Point_Type == "Highest" ~ Value + 0.75,
      Indicator == "Lending Rate" & Point_Type == "Lowest" ~ Value - 0.75,
      
      Indicator == "Deposit Rate" & Point_Type == "Initial" ~ Value - 0.70,
      Indicator == "Deposit Rate" & Point_Type == "Latest" ~ Value - 0.70,
      Indicator == "Deposit Rate" & Point_Type == "Highest" ~ Value + 0.70,
      Indicator == "Deposit Rate" & Point_Type == "Lowest" ~ Value - 0.70,
      
      TRUE ~ Value
    )
  )

latest_interest <- interest_df %>%
  group_by(Indicator) %>%
  filter(Year == max(Year)) %>%
  ungroup()

latest_label <- paste0(
  "Latest Position\n",
  "Lending Rate: ",
  sprintf("%.2f%%", latest_interest$Value[latest_interest$Indicator == "Lending Rate"]),
  "\nDeposit Rate: ",
  sprintf("%.2f%%", latest_interest$Value[latest_interest$Indicator == "Deposit Rate"])
)

p_interest_static <- ggplot() +
  
  geom_line(
    data = interest_df,
    aes(x = Year, y = Value, colour = Indicator),
    linewidth = 1.35
  ) +
  
  geom_point(
    data = interest_df,
    aes(x = Year, y = Value, colour = Indicator),
    size = 2.6
  ) +
  
  geom_point(
    data = interest_key,
    aes(x = Year, y = Value),
    colour = highlight_colour,
    size = 3.8
  ) +
  
  geom_segment(
    data = interest_key,
    aes(
      x = Year,
      xend = Label_X,
      y = Value,
      yend = Label_Y
    ),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.4
  ) +
  
  geom_label(
    data = interest_key,
    aes(x = Label_X, y = Label_Y, label = Label),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 2.75,
    fontface = "bold",
    label.padding = unit(0.20, "lines"),
    label.r = unit(0.12, "lines"),
    linewidth = 0.25
  ) +
  
  annotate(
    "label",
    x = 2018.5,
    y = max(interest_df$Value, na.rm = TRUE) + 0.9,
    label = latest_label,
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.25,
    linewidth = 0.3
  ) +
  
  scale_colour_manual(
    values = c(
      "Lending Rate" = main_colour,
      "Deposit Rate" = "#1F77B4"
    )
  ) +
  
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  
  labs(
    title = "Malaysia Borrowing and Saving Environment",
    subtitle = "Lending rate and deposit rate, 2000–2024",
    x = "Year",
    y = "Interest Rate (%)",
    colour = "",
    caption = "Source: World Bank Open Data | Note: Lending rate represents borrowing cost, while deposit rate represents return to savers."
  ) +
  
  theme_corporate() +
  theme(
    legend.position = "top"
  )

p_interest_static

ggsave(
  "visuals/storyboard/frame_08_borrowing_and_saving_environment_2000_2024.png",
  p_interest_static,
  width = 12,
  height = 7,
  dpi = 300
)

# ------------------------------------------------------------
# Interactive Plotly Version
# ------------------------------------------------------------

p_interest_interactive <- plot_ly() %>%
  add_lines(
    data = interest_wide,
    x = ~Year,
    y = ~`Lending Rate`,
    name = "Lending Rate",
    line = list(color = "#0B2545", width = 3),
    hovertemplate = "Year: %{x}<br>Lending Rate: %{y:.2f}%<extra></extra>"
  ) %>%
  add_lines(
    data = interest_wide,
    x = ~Year,
    y = ~`Deposit Rate`,
    name = "Deposit Rate",
    line = list(color = "#1F77B4", width = 3),
    hovertemplate = "Year: %{x}<br>Deposit Rate: %{y:.2f}%<extra></extra>"
  ) %>%
  layout(
    title = list(
      text = "<b>Malaysia Borrowing and Saving Environment</b><br><sup>Lending rate and deposit rate, 2000–2024</sup>",
      x = 0.02,
      xanchor = "left"
    ),
    xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "lightgrey"),
    yaxis = list(title = "Interest Rate (%)", showgrid = TRUE, gridcolor = "lightgrey"),
    hovermode = "x unified",
    legend = list(orientation = "h", y = -0.2),
    plot_bgcolor = "white",
    paper_bgcolor = "white",
    margin = list(t = 90, b = 80, l = 70, r = 40)
  )

p_interest_interactive

htmlwidgets::saveWidget(
  p_interest_interactive,
  "visuals/interactive/frame_08_borrowing_and_saving_environment_2000_2024.html",
  selfcontained = FALSE
)

# ============================================================
# 14. Malaysia Domestic Credit to Private Sector
# ============================================================

# Business Question:
# How has access to domestic credit changed over time?

# Analytical Purpose:
# To evaluate the expansion of private sector financing
# and overall banking support to the economy.

# Output:
# Frame 09 – Malaysia Domestic Credit to Private Sector

credit_df <- dashboard_df %>%
  filter(Indicator == "Domestic Credit") %>%
  arrange(Year)

credit_key <- bind_rows(
  credit_df %>% filter(Year == min(Year)) %>% mutate(Point_Type = "Initial Level"),
  credit_df %>% filter(Year == max(Year)) %>% mutate(Point_Type = "Latest"),
  credit_df %>% filter(Value == max(Value)) %>% slice(1) %>% mutate(Point_Type = "Highest"),
  credit_df %>% filter(Value == min(Value)) %>% slice(1) %>% mutate(Point_Type = "Lowest"),
  credit_df %>% filter(Year == 2008) %>% mutate(Point_Type = "Global Financial Crisis"),
  credit_df %>% filter(Year == 2020) %>% mutate(Point_Type = "COVID-19 Shock"),
  credit_df %>% filter(Year == 2021) %>% mutate(Point_Type = "Recovery")
) %>%
  distinct(Year, .keep_all = TRUE) %>%
  arrange(Year) %>%
  mutate(
    Label = paste0(
      Point_Type,
      "\n",
      Year,
      ": ",
      sprintf("%.2f%%", Value)
    ),
    Label_X = case_when(
      Point_Type == "Initial Level" ~ Year + 1.4,
      Point_Type == "Latest" ~ Year - 1.2,
      Point_Type == "Lowest" ~ Year + 1.0,
      Point_Type == "Global Financial Crisis" ~ Year + 1.2,
      Point_Type == "Highest" ~ Year + 1.2,
      Point_Type == "COVID-19 Shock" ~ Year - 1.4,
      Point_Type == "Recovery" ~ Year - 1.7,
      TRUE ~ Year
    ),
    Label_Y = case_when(
      Point_Type == "Initial Level" ~ Value + 5.0,
      Point_Type == "Latest" ~ Value - 6.0,
      Point_Type == "Lowest" ~ Value - 5.5,
      Point_Type == "Global Financial Crisis" ~ Value - 5.0,
      Point_Type == "Highest" ~ Value + 6.0,
      Point_Type == "COVID-19 Shock" ~ Value + 3.0,
      Point_Type == "Recovery" ~ Value + 6.5,
      TRUE ~ Value + 5
    )
  )

p_credit <- ggplot(credit_df, aes(x = Year, y = Value)) +
  geom_ribbon(
    aes(ymin = min(credit_df$Value, na.rm = TRUE) - 5, ymax = Value),
    fill = area_colour,
    alpha = 0.55
  ) +
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(colour = main_colour, size = 2.6) +
  geom_point(
    data = credit_key,
    aes(x = Year, y = Value),
    colour = highlight_colour,
    size = 3.8
  ) +
  geom_segment(
    data = credit_key,
    aes(
      x = Year,
      xend = Label_X,
      y = Value,
      yend = Label_Y
    ),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.4
  ) +
  geom_label(
    data = credit_key,
    aes(x = Label_X, y = Label_Y, label = Label),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 3.0,
    fontface = "bold",
    label.padding = unit(0.22, "lines"),
    label.r = unit(0.12, "lines"),
    linewidth = 0.25
  ) +
  annotate(
    "label",
    x = 2014.5,
    y = max(credit_df$Value, na.rm = TRUE) + 11,
    label = "Interpretation\nCredit level is measured\nrelative to GDP",
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.2,
    linewidth = 0.3
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 4)) +
  scale_y_continuous(
    limits = c(
      min(credit_df$Value, na.rm = TRUE) - 10,
      max(credit_df$Value, na.rm = TRUE) + 18
    ),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Malaysia Domestic Credit Performance",
    subtitle = "Domestic credit to private sector by banks as percentage of GDP, 2000–2024",
    x = "Year",
    y = "Domestic Credit (% of GDP)",
    caption = "Source: World Bank Open Data | Note: A value above 100% means bank credit to the private sector exceeds the size of annual GDP."
  ) +
  theme_corporate() +
  theme(legend.position = "none")

p_credit

ggsave(
  "visuals/storyboard/frame_09_malaysia_domestic_credit_2000_2024.png",
  p_credit,
  width = 12,
  height = 7,
  dpi = 300
)

# ============================================================
# 15. Malaysia Banking Stability
# ============================================================

# Business Question:
# How healthy has Malaysia's banking sector been based on loan repayment quality?

# Analytical Purpose:
# To assess banking stability using the Non-performing Loan (NPL) ratio
# as an indicator of credit risk.

# Output:
# Frame 10 – Malaysia Banking Stability

npl_df <- dashboard_df %>%
  filter(Indicator == "Non-performing Loans") %>%
  arrange(Year)

npl_change <- (
  (last(npl_df$Value) - first(npl_df$Value)) /
    first(npl_df$Value)
) * 100

latest_npl <- npl_df %>%
  filter(Year == max(Year))

npl_key <- bind_rows(
  npl_df %>% filter(Year == min(Year)) %>% mutate(Point_Type = "Start"),
  npl_df %>% filter(Year == max(Year)) %>% mutate(Point_Type = "Latest"),
  npl_df %>% filter(Value == max(Value)) %>% slice(1) %>% mutate(Point_Type = "Highest Risk"),
  npl_df %>% filter(Value == min(Value)) %>% slice(1) %>% mutate(Point_Type = "Lowest Risk"),
  npl_df %>% filter(Year == 2008) %>% mutate(Point_Type = "Global Financial Crisis"),
  npl_df %>% filter(Year == 2020) %>% mutate(Point_Type = "COVID-19 Shock"),
  npl_df %>% filter(Year == 2021) %>% mutate(Point_Type = "Recovery")
) %>%
  distinct(Year, .keep_all = TRUE) %>%
  arrange(Year) %>%
  mutate(
    Label = paste0(
      Point_Type,
      "\n",
      Year,
      ": ",
      sprintf("%.2f%%", Value)
    ),
    Label_X = case_when(
      Year == min(npl_df$Year) ~ Year + 1.3,
      Year == max(npl_df$Year) ~ Year - 1.6,
      Year == 2008 ~ Year + 1.3,
      Year == 2020 ~ Year - 1.3,
      Year == 2021 ~ Year + 1.3,
      TRUE ~ Year
    ),
    Label_Y = case_when(
      Point_Type == "Highest Risk" ~ Value + 0.9,
      Point_Type == "Lowest Risk" ~ Value + 0.7,
      Point_Type == "Start" ~ Value + 0.8,
      Point_Type == "Latest" ~ Value + 0.7,
      Point_Type == "Global Financial Crisis" ~ Value + 0.8,
      Point_Type == "COVID-19 Shock" ~ Value + 0.7,
      Point_Type == "Recovery" ~ Value + 0.7,
      TRUE ~ Value + 0.6
    )
  )

p_npl <- ggplot(npl_df, aes(x = Year, y = Value)) +
  
  annotate("rect", xmin = min(npl_df$Year), xmax = max(npl_df$Year),
           ymin = 0, ymax = 2, fill = "#EAF2FB", alpha = 0.65) +
  annotate("rect", xmin = min(npl_df$Year), xmax = max(npl_df$Year),
           ymin = 2, ymax = 5, fill = "#FFF4E6", alpha = 0.65) +
  annotate("rect", xmin = min(npl_df$Year), xmax = max(npl_df$Year),
           ymin = 5, ymax = 10.5, fill = "#FDECEC", alpha = 0.65) +
  
  geom_hline(yintercept = 2, colour = "grey60", linewidth = 0.5, linetype = "dashed") +
  geom_hline(yintercept = 5, colour = "grey60", linewidth = 0.5, linetype = "dashed") +
  
  geom_line(colour = main_colour, linewidth = 1.35) +
  geom_point(colour = main_colour, size = 2.6) +
  
  geom_point(
    data = npl_key,
    aes(x = Year, y = Value),
    colour = highlight_colour,
    size = 3.8
  ) +
  
  geom_segment(
    data = npl_key,
    aes(
      x = Year,
      xend = Label_X,
      y = Value,
      yend = Label_Y
    ),
    inherit.aes = FALSE,
    colour = "grey55",
    linetype = "dashed",
    linewidth = 0.4
  ) +
  
  geom_label(
    data = npl_key,
    aes(x = Label_X, y = Label_Y, label = Label),
    inherit.aes = FALSE,
    fill = "white",
    colour = main_colour,
    size = 3.0,
    fontface = "bold",
    label.padding = unit(0.22, "lines"),
    label.r = unit(0.12, "lines"),
    linewidth = 0.25
  ) +
  
  annotate(
    "label",
    x = 2017.8,
    y = 8.8,
    label = paste0(
      "Bank Health Assessment\n",
      "Latest NPL (", latest_npl$Year, "): ",
      sprintf("%.2f%%", latest_npl$Value),
      "\nInterpretation: Low Credit Risk"
    ),
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.25,
    linewidth = 0.3
  ) +
  
  annotate(
    "label",
    x = 2017.8,
    y = 7.1,
    label = paste0(
      "Overall Change\n",
      min(npl_df$Year), "–", max(npl_df$Year), ": ",
      ifelse(npl_change >= 0, "+", ""),
      sprintf("%.1f%%", npl_change)
    ),
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.25,
    linewidth = 0.3
  ) +
  
  annotate("label", x = 2006.5, y = 1.0,
           label = "Excellent asset quality\nBelow 2%",
           fill = "white", colour = "#1F77B4",
           fontface = "bold", size = 2.9, linewidth = 0.25) +
  annotate("label", x = 2006.5, y = 3.5,
           label = "Moderate credit risk\n2% to 5%",
           fill = "white", colour = "#B36B00",
           fontface = "bold", size = 2.9, linewidth = 0.25) +
  annotate("label", x = 2006.5, y = 7.5,
           label = "Elevated credit risk\nAbove 5%",
           fill = "white", colour = highlight_colour,
           fontface = "bold", size = 2.9, linewidth = 0.25) +
  
  scale_x_continuous(breaks = seq(min(npl_df$Year), max(npl_df$Year), by = 3)) +
  scale_y_continuous(
    limits = c(0, 10.5),
    breaks = seq(0, 10, by = 1),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Malaysia Banking Stability",
    subtitle = "Bank non-performing loans to total gross loans, 2005–2023",
    x = "Year",
    y = "NPL Ratio (%)",
    caption = "Source: World Bank Open Data / Global Financial Development Database | Note: Lower NPL indicates stronger loan repayment quality."
  ) +
  theme_corporate() +
  theme(legend.position = "none")

p_npl

ggsave(
  "visuals/storyboard/frame_10_malaysia_banking_stability_npl_2005_2023.png",
  p_npl,
  width = 12,
  height = 7,
  dpi = 300
)

# ============================================================
# 16. Malaysia Economic Relationship Overview
# ============================================================

# Business Question:
# Which economic indicators demonstrate the strongest statistical relationships?

# Analytical Purpose:
# To identify meaningful correlations among economic, household
# and banking indicators before conducting detailed relationship analysis.

# Output:
# Frame 11 – Malaysia Economic Relationship Overview

library(reshape2)
library(ggplot2)
library(dplyr)
library(patchwork)

# ------------------------------------------------------------
# 16.1 Prepare Correlation Matrix
# ------------------------------------------------------------

correlation_df <- dashboard_df %>%
  select(Year, Indicator, Value) %>%
  pivot_wider(
    names_from = Indicator,
    values_from = Value
  ) %>%
  arrange(Year)

correlation_matrix <- correlation_df %>%
  select(-Year) %>%
  cor(
    use = "pairwise.complete.obs",
    method = "pearson"
  )

# ------------------------------------------------------------
# 16.2 Prepare Heatmap Data
# ------------------------------------------------------------

cor_heatmap <- reshape2::melt(correlation_matrix)

names(cor_heatmap) <- c(
  "Indicator1",
  "Indicator2",
  "Correlation"
)

# ------------------------------------------------------------
# 16.3 Correlation Heatmap
# ------------------------------------------------------------

p_heatmap <- ggplot(
  cor_heatmap,
  aes(
    x = Indicator1,
    y = Indicator2,
    fill = Correlation
  )
) +
  geom_tile(
    colour = "white",
    linewidth = 0.40
  ) +
  geom_text(
    aes(label = sprintf("%.2f", Correlation)),
    size = 3.0,
    colour = "black",
    fontface = "bold"
  ) +
  scale_fill_gradient2(
    low = "#B22222",
    mid = "white",
    high = main_colour,
    midpoint = 0,
    limits = c(-1, 1),
    name = "Correlation"
  ) +
  labs(
    title = "Correlation Matrix of Economic Indicators",
    subtitle = "Pearson correlation coefficients, 2000–2024"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      size = 8.5
    ),
    axis.text.y = element_text(size = 8.5),
    plot.title = element_text(
      size = 17,
      face = "bold",
      colour = main_colour
    ),
    plot.subtitle = element_text(size = 10.5),
    legend.position = "right",
    panel.grid = element_blank()
  )

# ------------------------------------------------------------
# 16.4 Create Unique Correlation Pair Table
# ------------------------------------------------------------

cor_table <- as.data.frame(as.table(correlation_matrix))

names(cor_table) <- c(
  "Indicator1",
  "Indicator2",
  "Correlation"
)

cor_table <- cor_table %>%
  filter(Indicator1 != Indicator2) %>%
  rowwise() %>%
  mutate(
    Pair = paste(
      sort(c(Indicator1, Indicator2)),
      collapse = " | "
    )
  ) %>%
  ungroup() %>%
  distinct(Pair, .keep_all = TRUE) %>%
  mutate(
    Absolute = abs(Correlation)
  )

# ------------------------------------------------------------
# 16.5 Data-driven Thematic Relationship Ranking
# ------------------------------------------------------------

household_indicators <- c(
  "Income per Capita",
  "Household Consumption",
  "Gross Domestic Savings",
  "Inflation"
)

banking_indicators <- c(
  "Lending Rate",
  "Deposit Rate",
  "Domestic Credit",
  "Non-performing Loans"
)

household_relationships <- cor_table %>%
  filter(
    Indicator1 %in% household_indicators,
    Indicator2 %in% household_indicators
  ) %>%
  arrange(desc(Absolute)) %>%
  slice_head(n = 4)

banking_relationships <- cor_table %>%
  filter(
    Indicator1 %in% banking_indicators,
    Indicator2 %in% banking_indicators
  ) %>%
  arrange(desc(Absolute)) %>%
  slice_head(n = 4)

household_relationships
banking_relationships

# ------------------------------------------------------------
# 16.6 Relationship Summary Panel
# ------------------------------------------------------------

summary_text <- paste0(
  "Strong Household Relationships\n\n",
  paste0(
    seq_len(nrow(household_relationships)), ". ",
    household_relationships$Indicator1, " ↔ ",
    household_relationships$Indicator2,
    "\nr = ", round(household_relationships$Correlation, 2),
    collapse = "\n\n"
  ),
  "\n\nStrong Banking / Financial System Relationships\n\n",
  paste0(
    seq_len(nrow(banking_relationships)), ". ",
    banking_relationships$Indicator1, " ↔ ",
    banking_relationships$Indicator2,
    "\nr = ", round(banking_relationships$Correlation, 2),
    collapse = "\n\n"
  )
)

p_summary <- ggplot() +
  annotate(
    "label",
    x = 0.03,
    y = 0.97,
    label = summary_text,
    hjust = 0,
    vjust = 1,
    fill = "white",
    colour = main_colour,
    size = 3.5,
    fontface = "bold",
    label.padding = unit(0.45, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25
  ) +
  xlim(0, 1) +
  ylim(0, 1) +
  labs(title = "Data-driven Relationship Summary") +
  theme_void() +
  theme(
    plot.title = element_text(
      size = 15,
      face = "bold",
      colour = main_colour,
      hjust = 0
    ),
    plot.margin = margin(10, 20, 10, 10)
  )

# ------------------------------------------------------------
# 16.7 Combine Heatmap and Summary
# ------------------------------------------------------------

frame11 <- p_heatmap + p_summary +
  plot_layout(widths = c(1.55, 1.15)) +
  plot_annotation(
    title = "Malaysia Economic Relationship Overview",
    subtitle = "Correlation analysis identifies the strongest relationships within household and financial system indicators.",
    caption = "Source: World Bank Open Data | Pearson correlation using pairwise complete observations.",
    theme = theme(
      plot.title = element_text(
        size = 20,
        face = "bold",
        colour = main_colour
      ),
      plot.subtitle = element_text(
        size = 12,
        colour = "grey20"
      ),
      plot.caption = element_text(
        size = 9,
        colour = "grey40"
      )
    )
  )

frame11

ggsave(
  "visuals/storyboard/frame_11_economic_relationship_overview.png",
  frame11,
  width = 17,
  height = 9,
  dpi = 300
)

# ============================================================
# 17. Malaysia Selected Economic Relationships
# ============================================================

# Business Question:
# How are household income, borrowing costs, consumption,
# savings and banking stability interconnected?

# Analytical Purpose:
# To investigate the most economically meaningful relationships
# identified from the correlation analysis using regression analysis.

# Output:
# Frame 12 – Malaysia Selected Economic Relationships

library(patchwork)
library(broom)

relationship_df <- dashboard_df %>%
  select(Year, Indicator, Value) %>%
  pivot_wider(
    id_cols = Year,
    names_from = Indicator,
    values_from = Value
  ) %>%
  arrange(Year)

classify_relationship <- function(r) {
  case_when(
    abs(r) >= 0.80 ~ "Very Strong",
    abs(r) >= 0.60 ~ "Strong",
    abs(r) >= 0.40 ~ "Moderate",
    abs(r) >= 0.20 ~ "Weak",
    TRUE ~ "Very Weak"
  )
}

relationship_plot <- function(data, x_var, y_var, title, x_lab, y_lab, insight) {
  
  plot_df <- data %>%
    select(Year, all_of(x_var), all_of(y_var)) %>%
    drop_na()
  
  r <- cor(plot_df[[x_var]], plot_df[[y_var]])
  model <- lm(plot_df[[y_var]] ~ plot_df[[x_var]])
  model_summary <- broom::glance(model)
  
  r_squared <- model_summary$r.squared
  p_value <- model_summary$p.value
  
  strength <- classify_relationship(r)
  direction <- ifelse(r >= 0, "Positive", "Negative")
  line_colour <- ifelse(r >= 0, main_colour, highlight_colour)
  
  stat_label <- paste0(
    strength, " ", direction,
    "\n",
    "r = ", sprintf("%.2f", r),
    "\n",
    "R² = ", sprintf("%.2f", r_squared),
    "\n",
    "p = ", ifelse(p_value < 0.001, "<0.001", sprintf("%.3f", p_value))
  )
  
  ggplot(plot_df, aes(x = .data[[x_var]], y = .data[[y_var]])) +
    geom_point(
      colour = main_colour,
      size = 3,
      alpha = 0.85
    ) +
    geom_smooth(
      method = "lm",
      formula = y ~ x,
      se = FALSE,
      colour = line_colour,
      linewidth = 1.1
    ) +
    annotate(
      "label",
      x = Inf,
      y = Inf,
      hjust = 1.05,
      vjust = 1.10,
      label = stat_label,
      fill = "white",
      colour = main_colour,
      fontface = "bold",
      size = 3.0,
      linewidth = 0.25
    ) +
    labs(
      title = title,
      subtitle = insight,
      x = x_lab,
      y = y_lab
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 12, face = "bold", colour = main_colour),
      plot.subtitle = element_text(size = 9.5, colour = "grey25"),
      axis.title = element_text(size = 9),
      axis.text = element_text(size = 8),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey90")
    )
}

p_rel_1 <- relationship_plot(
  relationship_df,
  "Income per Capita",
  "Household Consumption",
  "Does higher income translate into higher spending?",
  "Income per Capita",
  "Household Consumption",
  "Rising income is compared with household spending behaviour."
)

p_rel_2 <- relationship_plot(
  relationship_df,
  "Lending Rate",
  "Household Consumption",
  "Do borrowing costs affect household spending?",
  "Lending Rate (%)",
  "Household Consumption",
  "Borrowing cost is compared with household consumption behaviour."
)

p_rel_3 <- relationship_plot(
  relationship_df,
  "Income per Capita",
  "Non-performing Loans",
  "Does higher income relate to stronger loan repayment?",
  "Income per Capita",
  "NPL Ratio (%)",
  "Income growth is compared with banking asset quality."
)

p_rel_4 <- relationship_plot(
  relationship_df,
  "Household Consumption",
  "Gross Domestic Savings",
  "Does higher spending reduce national savings?",
  "Household Consumption",
  "Gross Domestic Savings (% of GDP)",
  "Consumption behaviour is compared with national saving capacity."
)

p_selected_relationships <- (p_rel_1 | p_rel_2) / (p_rel_3 | p_rel_4) +
  plot_annotation(
    title = "Malaysia Selected Economic Relationships",
    subtitle = "Four relationships selected based on statistical strength, economic relevance and household impact",
    caption = "Source: World Bank Open Data | Method: Pearson correlation and linear regression using available paired observations",
    theme = theme(
      plot.title = element_text(size = 20, face = "bold", colour = main_colour),
      plot.subtitle = element_text(size = 12, colour = "grey20"),
      plot.caption = element_text(size = 9, colour = "grey40")
    )
  )

p_selected_relationships

ggsave(
  "visuals/storyboard/frame_12_selected_economic_relationships_2000_2024.png",
  p_selected_relationships,
  width = 14,
  height = 9,
  dpi = 300
)

# ============================================================
# 18. Malaysia Executive Economic Assessment Dashboard
# ============================================================

library(patchwork)

dashboard_card_df <- dashboard_df %>%
  arrange(Indicator, Year)

assessment_rules <- tibble(
  Indicator = c(
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
  ),
  Desired_Direction = c(
    "Higher",
    "Lower",
    "Lower",
    "Higher",
    "Higher",
    "Higher",
    "Lower",
    "Higher",
    "Higher",
    "Lower"
  ),
  Theme_Group = c(
    "Economic Performance",
    "Economic Performance",
    "Economic Performance",
    "Household Behaviour",
    "Household Behaviour",
    "Household Behaviour",
    "Financial System",
    "Financial System",
    "Financial System",
    "Financial System"
  ),
  Theme_Colour = c(
    "#0B2545",
    "#0B2545",
    "#0B2545",
    "#2E7D32",
    "#2E7D32",
    "#2E7D32",
    "#B36B00",
    "#B36B00",
    "#B36B00",
    "#B36B00"
  ),
  Theme_Fill = c(
    "#EAF2FB",
    "#EAF2FB",
    "#EAF2FB",
    "#EAF7EA",
    "#EAF7EA",
    "#EAF7EA",
    "#FFF4E6",
    "#FFF4E6",
    "#FFF4E6",
    "#FFF4E6"
  )
)

indicator_summary_card <- dashboard_card_df %>%
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
      Trend == "Stable" ~ "Stable",
      TRUE ~ "Less Favourable"
    ),
    Assessment_Colour = case_when(
      Assessment == "Favourable" ~ "#2E7D32",
      Assessment == "Less Favourable" ~ "#B22222",
      TRUE ~ "#6C757D"
    ),
    First_Label = case_when(
      Indicator %in% c("Income per Capita", "Household Consumption") ~
        paste0("US$", scales::comma(round(First_Value, 0))),
      TRUE ~ paste0(sprintf("%.2f", First_Value), "%")
    ),
    Latest_Label = case_when(
      Indicator %in% c("Income per Capita", "Household Consumption") ~
        paste0("US$", scales::comma(round(Latest_Value, 0))),
      TRUE ~ paste0(sprintf("%.2f", Latest_Value), "%")
    ),
    Period_Label = paste0(
      First_Year, ": ", First_Label,
      "  →  ",
      Latest_Year, ": ", Latest_Label
    )
  )

create_executive_card <- function(indicator_name) {
  
  card_data <- dashboard_card_df %>%
    filter(Indicator == indicator_name)
  
  summary_data <- indicator_summary_card %>%
    filter(Indicator == indicator_name)
  
  y_min <- min(card_data$Value, na.rm = TRUE)
  y_max <- max(card_data$Value, na.rm = TRUE)
  y_range <- y_max - y_min
  
  if (y_range == 0) {
    y_range <- 1
  }
  
  ggplot(card_data, aes(x = Year, y = Value)) +
    geom_ribbon(
      aes(
        ymin = y_min - (0.05 * y_range),
        ymax = Value
      ),
      fill = summary_data$Theme_Colour,
      alpha = 0.14
    ) +
    geom_line(
      colour = summary_data$Theme_Colour,
      linewidth = 1.15
    ) +
    geom_point(
      data = card_data %>% filter(Year == min(Year)),
      aes(x = Year, y = Value),
      colour = "grey45",
      size = 2.4
    ) +
    geom_point(
      data = card_data %>% filter(Year == max(Year)),
      aes(x = Year, y = Value),
      colour = summary_data$Assessment_Colour,
      size = 3.0
    ) +
    annotate(
      "label",
      x = min(card_data$Year),
      y = y_max + (0.36 * y_range),
      label = indicator_name,
      hjust = 0,
      vjust = 1,
      fill = "white",
      colour = summary_data$Theme_Colour,
      fontface = "bold",
      size = 3.05,
      linewidth = 0
    ) +
    annotate(
      "label",
      x = max(card_data$Year),
      y = y_max + (0.36 * y_range),
      label = paste0("Assessment\n", summary_data$Assessment),
      hjust = 1,
      vjust = 1,
      fill = "white",
      colour = summary_data$Assessment_Colour,
      fontface = "bold",
      size = 2.45,
      linewidth = 0.25
    ) +
    annotate(
      "label",
      x = min(card_data$Year),
      y = y_min - (0.23 * y_range),
      label = summary_data$Period_Label,
      hjust = 0,
      vjust = 0,
      fill = "white",
      colour = "grey25",
      size = 2.45,
      linewidth = 0
    ) +
    scale_x_continuous(
      limits = c(min(card_data$Year), max(card_data$Year)),
      breaks = c(min(card_data$Year), max(card_data$Year))
    ) +
    scale_y_continuous(
      limits = c(
        y_min - (0.30 * y_range),
        y_max + (0.42 * y_range)
      )
    ) +
    labs(
      x = NULL,
      y = NULL
    ) +
    theme_void() +
    theme(
      plot.background = element_rect(
        fill = summary_data$Theme_Fill,
        colour = "grey75",
        linewidth = 0.6
      ),
      plot.margin = margin(7, 7, 7, 7)
    )
}

# ------------------------------------------------------------
# Create cards in the exact presentation order
# ------------------------------------------------------------

p_card_gdp <- create_executive_card("GDP Growth")
p_card_inflation <- create_executive_card("Inflation")
p_card_unemployment <- create_executive_card("Unemployment")
p_card_income <- create_executive_card("Income per Capita")
p_card_consumption <- create_executive_card("Household Consumption")

p_card_savings <- create_executive_card("Gross Domestic Savings")
p_card_lending <- create_executive_card("Lending Rate")
p_card_deposit <- create_executive_card("Deposit Rate")
p_card_credit <- create_executive_card("Domestic Credit")
p_card_npl <- create_executive_card("Non-performing Loans")

favourable_count <- indicator_summary_card %>%
  filter(Assessment == "Favourable") %>%
  nrow()

less_favourable_count <- indicator_summary_card %>%
  filter(Assessment == "Less Favourable") %>%
  nrow()

snapshot_text <- paste0(
  "Executive Snapshot\n\n",
  "Overall assessment: ",
  favourable_count, " favourable indicators, ",
  less_favourable_count, " less favourable indicators.\n\n",
  "• Economic performance remained resilient across major shocks.\n",
  "• Household income and consumption improved over the long term.\n",
  "• Savings behaviour requires continued monitoring.\n",
  "• Banking stability strengthened as non-performing loans declined.\n",
  "• Financing conditions supported private sector activity."
)

p_executive_snapshot <- ggplot() +
  annotate(
    "rect",
    xmin = 0, xmax = 1,
    ymin = 0, ymax = 1,
    fill = "#F7F9FB",
    colour = "grey75",
    linewidth = 0.6
  ) +
  annotate(
    "label",
    x = 0.03,
    y = 0.90,
    label = snapshot_text,
    hjust = 0,
    vjust = 1,
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.9,
    label.padding = unit(0.50, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25
  ) +
  annotate(
    "label",
    x = 0.98,
    y = 0.90,
    label = paste0(
      "Colour Guide\n\n",
      "Blue: Economic performance\n",
      "Green: Household behaviour\n",
      "Brown: Financial system"
    ),
    hjust = 1,
    vjust = 1,
    fill = "white",
    colour = main_colour,
    fontface = "bold",
    size = 3.5,
    label.padding = unit(0.45, "lines"),
    label.r = unit(0.15, "lines"),
    linewidth = 0.25
  ) +
  xlim(0, 1) +
  ylim(0, 1) +
  theme_void() +
  theme(
    plot.margin = margin(7, 7, 7, 7)
  )

# ------------------------------------------------------------
# Arrange dashboard cards in final agreed order
# ------------------------------------------------------------

kpi_cards <- (
  p_card_gdp | p_card_inflation | p_card_unemployment | p_card_income | p_card_consumption
) /
  (
    p_card_savings | p_card_lending | p_card_deposit | p_card_credit | p_card_npl
  )

frame13_v2 <- p_executive_snapshot / kpi_cards +
  plot_layout(
    heights = c(0.85, 2.6)
  ) +
  plot_annotation(
    title = "Malaysia Executive Economic Assessment Dashboard",
    subtitle = "Executive snapshot, latest indicator assessment and long-term area sparkline trends",
    caption = "Source: World Bank Open Data | Note: Assessment is based on desired indicator direction and first-to-latest available values.",
    theme = theme(
      plot.title = element_text(size = 21, face = "bold", colour = main_colour),
      plot.subtitle = element_text(size = 12, colour = "grey20"),
      plot.caption = element_text(size = 9, colour = "grey40")
    )
  )

frame13_v2

ggsave(
  "visuals/storyboard/frame_13_executive_assessment_dashboard_v2.png",
  frame13_v2,
  width = 18,
  height = 11,
  dpi = 300
)
