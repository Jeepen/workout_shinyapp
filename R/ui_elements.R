# Load necessary UI packages
library(shiny)

# Function for the login UI
login_ui <- function() {
  tabPanel("Login", 
           textInput("user", "Username"),
           passwordInput("password", "Password"),
           actionButton("login", "Login"),
           textOutput("login_message"),
           br(),
           textInput("new_username", "New Username"),
           passwordInput("new_password", "New Password"),
           actionButton("register", "Register"),
           textOutput("register_message")
  )
}

# Function for the dashboard UI
dashboard_ui <- function() {
  tabPanel("Dashboard",
           fluidPage(
             titlePanel("Workout Dashboard"),
             sidebarLayout(
               sidebarPanel(
                 h3("Metrics"),
                 textOutput("max_weight"),
                 textOutput("recent_workouts"),
                 actionButton("add_workout", "Log a New Workout")
               ),
               mainPanel(
                 h3("Welcome to Your Dashboard!"),
                 textOutput("welcome_message")  # Add a welcome message output
               )
             )
           )
  )
}

# Function for the main UI
main_ui <- function() {
  navbarPage("Workout Tracker", id = "navbar",  # Add an ID here
             login_ui(),
             dashboard_ui(),
             workoutEntryUI()  # Keep the workout entry UI
             # other UI elements...
  )
}

# Workout Entry UI ----
workoutEntryUI <- function(id = "workoutEntry") {
  ns <- NS(id)  # Namespacing for modular components
  tagList(
    h3("Enter Workout"),
    textInput(ns("exercise"), "Exercise Name", placeholder = "e.g., Bench Press"),
    numericInput(ns("weight"), "Weight (kg)", value = NULL, min = 0),
    numericInput(ns("reps"), "Reps", value = NULL, min = 1),
    dateInput(ns("date"), "Date", value = Sys.Date()),
    actionButton(ns("save_workout"), "Save Workout", class = "btn-primary")
  )
}

# Workout History UI ----
workoutHistoryUI <- function(id = "workoutHistory") {
  ns <- NS(id)
  tagList(
    h3("Workout History"),
    tableOutput(ns("workout_table")),  # Displays past workouts in a table
    actionButton(ns("refresh_history"), "Refresh History")
  )
}

# Progress UI ----
workoutAnalysisUI <- function(id = "workoutAnalysis") {
  ns <- NS(id)
  tagList(
    h3("Progress"),
    plotOutput(ns("weight_trend")),  # Displays trend plot from targets
    selectInput(ns("exercise_select"), "Select Exercise", choices = NULL),  # For selecting specific exercises
    actionButton(ns("update_trend"), "Update Trend")
  )
}
