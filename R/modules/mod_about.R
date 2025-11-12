# =============================================================================
# mod_about.R — About Section Module
#
# Purpose:
#   - Provides an "About" tab with information about the California Soil Health Reports app
#   - Similar to the "Learn More" tab in dirt-data-reports
#
# =============================================================================

mod_about_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(
      class = "container-fluid",
      style = "padding: 20px;",
      
      # Header
      div(
        class = "row",
        div(
          class = "col-12",
          h2("About California Soil Health Reports", style = "color: #2c3e50; margin-bottom: 20px;"),
          hr()
        )
      ),
      
      # Main content
      div(
        class = "row",
        div(
          class = "col-12",
          
          # App Description
          div(
            class = "well",
            h3("What is this app?", style = "color: #34495e;"),
            p("The California Soil Health Reports app is a web-based tool that helps agricultural producers, researchers, and extension professionals generate comprehensive soil health reports from their field data. Simply upload your data, customize your project information, and download reports in HTML or DOCX format.")
          ),
          
          # Example Report Section
          div(
            class = "well",
            h3("Example Report", style = "color: #34495e;"),
            p("View a sample soil health report to see what your generated reports will look like:"),
            div(
              style = "margin-top: 15px; border: 1px solid #ddd; border-radius: 5px; overflow: hidden;",
              tags$iframe(
                src = "examples/example_report.html",
                style = "width: 100%; height: 600px; border: none;",
                title = "Example Soil Health Report"
              )
            )
          ),
          
          
          # Soil Health Indicators
          div(
            class = "well",
            h3("Soil Health Indicators", style = "color: #34495e;"),
            p("The reports include comprehensive analysis of four key soil health categories:"),
            tags$ul(
              tags$li(tags$strong("Physical:"), "Soil texture, wet aggregate stability, infiltration rate"),
              tags$li(tags$strong("Chemical:"), "pH, cation exchange capacity, essential plant nutrients, nitrogen forms"),
              tags$li(tags$strong("Biological:"), "Microbial biomass, fungi:bacteria ratios, biopores, visible biodiversity"),
              tags$li(tags$strong("Carbon:"), "Total carbon, soil organic matter, soil respiration, active carbon")
            ),
            p("Each indicator includes detailed explanations of what it measures, why it's important, and how it was analyzed in your specific assessment.")
          ),
          
          
          # Development & Credits
          div(
            class = "well",
            h3("Development & Credits", style = "color: #34495e;"),
            p("This application was developed by ", tags$strong("Maegen Simmonds"), " in collaboration with UC Agriculture and Natural Resources (UCANR) and the California Farm Demonstration Network (CFDN)."),
            p("Source code and documentation are available on ", 
              tags$a(href = "https://github.com/msimmond/ca-soil-health-reports", target = "_blank", "GitHub", .noWS = "after"), "."),
            p("The soil health reporting functions build on and reuse functions originally developed in the {soils} R package, created by the Washington State Department of Agriculture and Washington State University as part of the Washington Soil Health Initiative (WASHI) ",
              "(Ryan J.N. et al., 2024. Visualize and Report Soil Health Data with {soils}. Washington Soil Health Initiative. ",
              tags$a(href = "https://github.com/WA-Department-of-Agriculture/soils", target = "_blank", "GitHub", .noWS = "after"), ")."),
            p("Portions of the data-validation workflow and template design were adapted from the dirt-data-reports application, with all adaptations modified for California Soil Health workflows ",
              "(Ryan J., Shapiro T., McIlquham M., Michel L., Potter L., Griffin LaHue D., Gelardi D. Dirt Data Reports, 2025. ",
              tags$a(href = "https://wsda.shinyapps.io/dirt-data-reports/", target = "_blank", "https://wsda.shinyapps.io/dirt-data-reports/", .noWS = "after"), " | ",
              tags$a(href = "https://github.com/WA-Department-of-Agriculture/dirt-data-reports", target = "_blank", "GitHub", .noWS = "after"), ")."),
            p("Development of this application was supported by the UC Climate Action Research Grants Program, Grant #R02CP6986.")
          ),
          
          # Contact Information
          div(
            class = "well",
            h3("Contact & Support", style = "color: #34495e;"),
            p("For technical support or questions about soil health interpretation, please contact your local UC Cooperative Extension office or visit the", 
              tags$a(href = "https://ucanr.edu/", target = "_blank", "UCANR website", .noWS = "after"), ".")
          )
        )
      )
    )
  )
}

mod_about_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed for the About page
  })
}
