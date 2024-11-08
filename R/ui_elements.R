# ui_elements.R

library(shiny)
library(shinyWidgets)

# Login UI component
login_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(
      h2("Login"),
      textInput(ns("username"), "Username"),
      passwordInput(ns("password"), "Password"),
      actionButton(ns("login_button"), "Login"),
      p(),
      actionButton(ns("register_switch_button"), "Register", class = "btn-link")
    )
  )
}

# Registration UI component
register_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(
      h2("Register"),
      textInput(ns("new_username"), "Choose a Username"),
      passwordInput(ns("new_password"), "Choose a Password"),
      actionButton(ns("register_button"), "Register"),
      p(),
      actionButton(ns("login_switch_button"), "Back to Login", class = "btn-link")
    )
  )
}

# Main Dashboard UI component (placeholder example for when user is logged in)
dashboard_ui <- function(id) {
  ns <- NS(id)
  
  tabsetPanel(
    id = ns("dashboard_tabs"),
    tabPanel(
      "Workout Overview",
      h3("Welcome to your Dashboard"),
      verbatimTextOutput(ns("workout_summary"))
    ),
    tabPanel(
      "Add Workout",
      h3("Log a New Workout"),
      textInput(ns("exercise"), "Exercise Name"),
      numericInput(ns("weight"), "Weight (kg)", value = 0, min = 0),
      numericInput(ns("reps"), "Reps", value = 0, min = 0),
      numericInput(ns("sets"), "Sets", value = 0, min = 0),
      actionButton(ns("save_workout"), "Save Workout")
    )
  )
}
