# Load necessary packages
library(bcrypt)
library(DBI)
library(RSQLite)

# Function to validate an existing user's login credentials
validate_user <- function(db, username, password) {
  # Query to retrieve the hashed password from the database for the given username
  result <- dbGetQuery(db, "SELECT password FROM user_data WHERE user = ?", params = list(username))
  
  # Check if the username exists and if the password matches the hash in the database
  if (nrow(result) == 1 && checkpw(password, result$password)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# Function to register a new user by saving a hashed password in the database
register_user <- function(db, username, password) {
  # Check if the username already exists
  result <- dbGetQuery(db, "SELECT user FROM user_data WHERE user = ?", params = list(username))
  
  if (nrow(result) > 0) {
    return(FALSE)  # Username already exists
  } else {
    # Hash the password and insert the new user into the database
    hashed_pw <- hashpw(password)
    dbExecute(db, "INSERT INTO user_data (user, password) VALUES (?, ?)", params = list(username, hashed_pw))
    return(TRUE)
  }
}

# Function to initialize database and ensure the user_data table exists
initialize_db <- function(db) {
  # Create user_data table if it does not exist
  dbExecute(db, "CREATE TABLE IF NOT EXISTS user_data (user TEXT PRIMARY KEY, password TEXT)")
}

# handle_user_interactions function
handle_user_interactions <- function(input, output, session, db) {
  # Reactive values to store the user status
  session$userData <- reactiveValues(user = NULL)
  
  # Observe login attempt
  observeEvent(input$login_button, {
    req(input$login_user, input$login_password)
    
    # Fetch user data from the database
    query <- dbGetQuery(db, "SELECT * FROM user_data WHERE user = ?", params = list(input$login_user))
    
    # Check if user exists and password is correct
    if (nrow(query) > 0 && bcrypt::checkpw(input$login_password, query$password[1])) {
      session$userData$user <- input$login_user
      showModal(modalDialog("Login successful!", easyClose = TRUE))
      updateTabsetPanel(session, "tabs", selected = "Dashboard")
    } else {
      showModal(modalDialog("Incorrect username or password", easyClose = TRUE))
    }
  })
  
  # Observe registration attempt
  observeEvent(input$register_button, {
    req(input$register_user, input$register_password)
    
    # Check if username is already taken
    query <- dbGetQuery(db, "SELECT * FROM user_data WHERE user = ?", params = list(input$register_user))
    if (nrow(query) > 0) {
      showModal(modalDialog("Username already exists", easyClose = TRUE))
      return()
    }
    
    # Hash the password and store new user in the database
    hashed_pw <- bcrypt::hashpw(input$register_password)
    dbExecute(db, "INSERT INTO user_data (user, password) VALUES (?, ?)", params = list(input$register_user, hashed_pw))
    
    showModal(modalDialog("Registration successful! You can now log in.", easyClose = TRUE))
  })
}
# Function to render the dashboard with user-specific data
dashboard_server <- function(input, output, session, db) {
  observe({
    req(session$userData$user)  # Require a logged-in user
    
    # Retrieve the user’s workout data and calculate max weight (example)
    workout_data <- dbGetQuery(db, "SELECT * FROM workouts WHERE user = ?", params = list(session$userData$user))
    
    # Example metric: max weight lifted
    if (nrow(workout_data) > 0) {
      max_weight <- max(workout_data$weight, na.rm = TRUE)
      output$max_weight <- renderText(paste("Max weight lifted:", max_weight, "kg"))
    } else {
      output$max_weight <- renderText("No workout data available.")
    }
  })
}

# Function to add a new workout entry for the logged-in user
add_workout_entry <- function(db, user, exercise, weight, reps, sets) {
  dbExecute(db, "INSERT INTO workouts (user, exercise, weight, reps, sets) VALUES (?, ?, ?, ?, ?)",
            params = list(user, exercise, weight, reps, sets))
}
