# ========================================
# Script Name: _targets.R
#
# Description: Targets file for project pipeline
#
# Author: Jeppe Ekstrand Halkjær Madsen
#
# Date Created: 2024-11-03
# ========================================
  
# Load required libraries
library(targets)
library(dplyr)
library(ggplot2)
library(DBI)
library(RSQLite)

# Define target options
tar_option_set(
  packages = c("dplyr", "ggplot2", "DBI", "RSQLite"),  # Packages needed for all targets
  format = "rds"  # Default format for saved targets
)

# Define your target pipeline
list(
  # Target to load data from SQLite database
  tar_target(
    workout_data,
    {
      con <- dbConnect(RSQLite::SQLite(), "db/workout_data.sqlite")
      data <- dbReadTable(con, "workouts")
      dbDisconnect(con)
      data
    },
    cue = tar_cue(mode = "always")  # Always load fresh data each time
  ),
  
  # Target for data preprocessing (e.g., filtering outliers)
  tar_target(
    cleaned_data,
    workout_data %>%
      filter(reps > 0, weight > 0)  # Basic filtering
  ),
  
  # Target to calculate summary statistics (e.g., weekly average weights by exercise)
  tar_target(
    summary_stats,
    cleaned_data %>%
      group_by(user, exercise, week = as.Date(cut(date, "week"))) %>%
      summarize(avg_weight = mean(weight), total_reps = sum(reps), .groups = "drop")
  ),
  
  # Target to generate a ggplot plot (e.g., trends over time)
  tar_target(
    weight_trend_plot,
    ggplot(summary_stats, aes(x = week, y = avg_weight, color = exercise)) +
      geom_line() +
      labs(title = "Weekly Average Weight Lifted", x = "Week", y = "Average Weight") +
      theme_minimal()
  )
)