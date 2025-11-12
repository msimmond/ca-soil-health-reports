# =============================================================================
# mod_filters.R — Data Selection Module (UI + Server)
#
# Purpose:
#   - Provide dynamic UI inputs for selecting Producer / Year / Field
#   - Use renderUI to populate dropdowns based on uploaded data
#   - Handle step validation for stepper (Step 5)
#
# Inputs:
#   id    : Module namespace ID
#   state : reactiveValues, shared app state containing uploaded data
#
# Outputs:
#   - Dynamic UI inputs for selection (producer, year, field) using renderUI
#   - Report options (include_comparisons, include_maps)
#   - Updates state$step_5_valid when producer and year are selected
#
# Implementation Notes:
#   - Uses renderUI instead of updateSelectInput to avoid UI re-rendering issues
#   - Dropdowns are populated directly from state$data when UI is rendered
#   - Year dropdown depends on producer selection, field dropdown depends on both
# =============================================================================

mod_filters_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h4("Report Filters"),
    
    # Producer selection - use renderUI to get choices from state
    uiOutput(ns("producer_ui")),
    
    # Year selection - use renderUI to get choices from state
    uiOutput(ns("year_ui")),
    
    
    # Report options
    tags$hr(),
    h5("Report Options"),
    uiOutput(ns("comparisons_checkbox")),
    checkboxInput(
      ns("include_maps"),
      "Include field maps",
      value = TRUE
    ),
    
  )
}

# ---------------------------
# Filters Module Server
# ---------------------------
mod_filters_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Render producer dropdown with choices from state
    output$producer_ui <- renderUI({
      # Use filtered data if available, otherwise use original data
      data_to_use <- if (!is.null(state$filtered_data)) state$filtered_data else state$data
      
      if (!is.null(data_to_use) && "producer_id" %in% names(data_to_use)) {
        producers <- sort(unique(data_to_use$producer_id))
        selectInput(
          ns("producer"),
          "Select Producer:",
          choices = producers,
          selected = NULL
        )
      } else {
        selectInput(
          ns("producer"),
          "Select Producer:",
          choices = c("Please upload data first" = ""),
          selected = NULL
        )
      }
    })
    
    # Render year dropdown with choices based on selected producer
    output$year_ui <- renderUI({
      # Force reactivity to producer selection - use the actual input ID
      producer_selected <- input$producer
      
      # Use filtered data if available, otherwise use original data
      data_to_use <- if (!is.null(state$filtered_data)) state$filtered_data else state$data
      
      if (!is.null(data_to_use) && !is.null(producer_selected) && producer_selected != "") {
        years <- sort(unique(data_to_use$year[data_to_use$producer_id == producer_selected]))
        selectInput(
          ns("year"),
          "Select Year:",
          choices = years,
          selected = NULL
        )
      } else {
        selectInput(
          ns("year"),
          "Select Year:",
          choices = c("Please select a producer first" = ""),
          selected = NULL
        )
      }
    })
    
    # Conditionally show "Include regional comparisons" checkbox only if multiple producers exist
    output$comparisons_checkbox <- renderUI({
      # Use filtered data if available, otherwise use original data
      data_to_use <- if (!is.null(state$filtered_data)) state$filtered_data else state$data
      
      if (!is.null(data_to_use) && "producer_id" %in% names(data_to_use)) {
        n_producers <- length(unique(data_to_use$producer_id))
        
        if (n_producers > 1) {
          # Multiple producers - show the checkbox
          checkboxInput(
            ns("include_comparisons"),
            "Include regional comparisons",
            value = TRUE
          )
        } else {
          # Only one producer - hide checkbox and set to FALSE
          # Store FALSE in state so report doesn't try to show Other Fields
          state$include_comparisons <- FALSE
          return(NULL)  # Don't render anything
        }
      } else {
        # No data yet - show checkbox (will be hidden once data is loaded)
        checkboxInput(
          ns("include_comparisons"),
          "Include regional comparisons",
          value = TRUE
        )
      }
    })
    
    
    # Validate step 5 when producer and year are selected
    observe({
      req(input$producer, input$year)
      
      # Update state with selected values
      state$selected_producer <- input$producer
      state$selected_year <- input$year
      
      # Store checkbox values in state (include_comparisons may not exist if only one producer)
      if (!is.null(input$include_comparisons)) {
        state$include_comparisons <- input$include_comparisons
      } else {
        # If checkbox doesn't exist (single producer), set to FALSE
        state$include_comparisons <- FALSE
      }
      state$include_maps <- input$include_maps
      
      # Mark step 5 as valid if producer and year are selected
      if (input$producer != "" && input$year != "" && input$year != "NULL") {
        state$step_5_valid <- TRUE
      } else {
        state$step_5_valid <- FALSE
      }
    })
    
    # Also observe checkbox changes independently to update state
    observe({
      if (!is.null(input$include_comparisons)) {
        state$include_comparisons <- input$include_comparisons
      } else {
        state$include_comparisons <- FALSE
      }
    })
    
    observe({
      state$include_maps <- input$include_maps
    })
    
  })
}