# Load necessary packages
library(DBI)
library(RSQLite)
library(dplyr)

# Database Connection Function ----
connect_db <- function() {
  dbConnect(SQLite(), "db/workout_data.sqlite")
}

# Initialize Database with Table Schema ----
initialize_db <- function() {
  con <- dbConnect(RSQLite::SQLite(), "user_data.sqlite")
  if (!dbExistsTable(con, "users")) {
    dbExecute(con, "CREATE TABLE users (username TEXT PRIMARY KEY, password TEXT)")
  }  
  dbDisconnect(con)
}

# Save Workout Data ----
save_workout <- function(exercise, weight, reps, date) {
  con <- connect_db()
  # Insert a new workout into the 'workouts' table
  dbWriteTable(
    con,
    "workouts",
    data.frame(exercise = exercise, weight = weight, reps = reps, date = date),
    append = TRUE,
    row.names = FALSE
  )
  dbDisconnect(con)
}

# Get Workout History ----
get_workout_history <- function() {
  con <- connect_db()
  # Retrieve workout history data
  data <- dbReadTable(con, "workouts")
  dbDisconnect(con)
  
  data %>%
    arrange(desc(date)) %>%
    select(date, exercise, weight, reps)  # Arrange data by most recent first
}

# Calculate Weekly Averages for Progress ----
calculate_weekly_averages <- function() {
  con <- connect_db()
  data <- dbReadTable(con, "workouts")
  dbDisconnect(con)
  
  data %>%
    mutate(week = as.Date(cut(date, "week"))) %>%  # Group data by week
    group_by(exercise, week) %>%
    summarise(
      avg_weight = mean(weight, na.rm = TRUE),
      total_reps = sum(reps, na.rm = TRUE)
    ) %>%
    ungroup()
}
