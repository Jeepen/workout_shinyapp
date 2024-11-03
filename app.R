# Load Shiny and other required packages
library(shiny)
library(shinyWidgets)
library(DBI)
library(RSQLite)

# Source UI, server, and data helper scripts
source("R/ui_elements.R")
source("R/server_functions.R")
source("R/data_helpers.R")  # Added this line

# Initialize the database
db <- dbConnect(SQLite(), "workout_app.sqlite")
initialize_db(db)  # Ensure the user_data table exists

# Define the User Interface (UI) of the app
ui <- fluidPage(
  titlePanel("Workout Tracking App"),
  
  # Use a navbarPage to organize the layout
  navbarPage(
    "Workout App",
    id = "tabs",
    
    # Login/Register tab
    tabPanel(
      "Login",
      login_ui()  # Removed the unused argument here
    ),
    
    # Dashboard tab (shown after login)
    tabPanel(
      "Dashboard",
      value = "Dashboard",
      dashboard_ui()  # Removed the unused argument here
    ),
    
    # Register workout tab
    tabPanel(
      "Register Workout",
      value = "Register Workout",
      workoutEntryUI()  # Removed the unused argument here
    )
  )
)

# Define the Server logic of the app
server <- function(input, output, session) {
  # Handle user interactions: login and registration
  handle_user_interactions(input, output, session, db)
  
  # Only run dashboard and workout entry functions if a user is logged in
  observeEvent(session$userData$user, {
    req(session$userData$user)  # Ensure user is logged in
    
    # Render the dashboard and register workout server-side logic
    dashboard_server(input, output, session, db)
    workoutEntryServer(input, output, session, db)
  }, ignoreNULL = TRUE)
  
  # Disconnect from the database on app close
  onStop(function() {
    dbDisconnect(db)
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
