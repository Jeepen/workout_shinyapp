# server_functions.R

library(shiny)
library(RSQLite)
library(bcrypt)

# Initialize the database with tables if they don't exist
initialize_db <- function() {
  db <- dbConnect(SQLite(), "workout_app.sqlite")
  # Create users table if not exists
  dbExecute(db, "
    CREATE TABLE IF NOT EXISTS users (
      user_id INTEGER PRIMARY KEY,
      username TEXT UNIQUE,
      password TEXT
    )
  ")
  # Create workouts table if not exists
  dbExecute(db, "
    CREATE TABLE IF NOT EXISTS workouts (
      workout_id INTEGER PRIMARY KEY,
      user_id INTEGER,
      exercise TEXT,
      weight REAL,
      reps INTEGER,
      sets INTEGER,
      FOREIGN KEY(user_id) REFERENCES users(user_id)
    )
  ")
  dbDisconnect(db)
}

# Validate user login
validate_user <- function(username, password) {
  db <- dbConnect(SQLite(), "workout_app.sqlite")
  user <- dbGetQuery(db, "SELECT * FROM users WHERE username = ?", params = list(username))
  dbDisconnect(db)
  
  if (nrow(user) == 1 && checkpw(password, user$password)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# Register a new user
register_user <- function(username, password) {
  hashed_password <- hashpw(password)
  
  db <- dbConnect(SQLite(), "workout_app.sqlite")
  res <- tryCatch(
    {
      dbExecute(db, "INSERT INTO users (username, password) VALUES (?, ?)", params = list(username, hashed_password))
      TRUE
    },
    error = function(e) FALSE
  )
  dbDisconnect(db)
  return(res)
}

# Save a workout entry
save_workout <- function(user_id, exercise, weight, reps, sets) {
  db <- dbConnect(SQLite(), "workout_app.sqlite")
  dbExecute(db, "INSERT INTO workouts (user_id, exercise, weight, reps, sets) VALUES (?, ?, ?, ?, ?)",
            params = list(user_id, exercise, weight, reps, sets))
  dbDisconnect(db)
}

# Server-side logic for handling UI interactions
handle_user_interactions <- function(input, output, session) {
  # Reactive value to store login state and user ID
  user_data <- reactiveValues(logged_in = FALSE, user_id = NULL)
  
  # Observe Login Button
  observeEvent(input$login_ui_login_button, {
    username <- input$login_ui_username
    password <- input$login_ui_password
    
    if (validate_user(username, password)) {
      user_data$logged_in <- TRUE
      user_data$user_id <- username  # For simplicity, using username as the identifier
      output$workout_summary <- renderText("Welcome to your dashboard!")  # Show confirmation
      showTab(inputId = "dashboard_ui_dashboard_tabs", target = "Workout Overview")  # Show the dashboard
    } else {
      showNotification("Incorrect username or password", type = "error")
    }
  })
  
  # Observe Register Button
  observeEvent(input$login_ui_register_button, {
    username <- input$register_ui_new_username
    password <- input$register_ui_new_password
    
    if (register_user(username, password)) {
      showNotification("Registration successful! Please log in.", type = "message")
    } else {
      showNotification("Username already exists. Try a different one.", type = "error")
    }
  })
  
  # Observe Save Workout Button
  observeEvent(input$dashboard_ui_save_workout, {
    req(user_data$logged_in)
    
    exercise <- input$dashboard_ui_exercise
    weight <- input$dashboard_ui_weight
    reps <- input$dashboard_ui_reps
    sets <- input$dashboard_ui_sets
    
    if (!is.null(user_data$user_id)) {
      save_workout(user_data$user_id, exercise, weight, reps, sets)
      showNotification("Workout saved successfully!", type = "message")
    } else {
      showNotification("Please log in to save workouts.", type = "error")
    }
  })
}
