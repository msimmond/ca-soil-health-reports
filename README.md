# California Soil Health Reports Shiny App

A comprehensive Shiny application for generating soil health reports for California agricultural producers. The app provides an 8-step workflow for data upload, filtering, analysis, and report generation using integrated soil health functions and Quarto templates.

## Features

- **8-step workflow**: Guided process from data upload to report generation
- **Data filtering**: Filter by crop, soil type, and other variables with cross-filtering
- **Quality assurance**: Comprehensive data validation with user-friendly error messages
- **Grouping options**: Compare different fields or treatments with validation
- **Interactive previews**: Real-time data preview and validation feedback
- **Multiple outputs**: HTML and DOCX report formats
- **Report customization**: Control regional comparisons and map inclusion via checkboxes
- **Example report**: Preview sample reports in the About tab
- **Template system**: Excel template with detailed instructions and column guide
- **Configuration-backed**: Filters, grouping options, and validation rules are read from CSV/YAML files; the stepper and UI layout are defined in code

## Prerequisites

### Required Software

1. **R** (version 4.0 or higher)
2. **Quarto CLI** - Install from https://quarto.org/
3. **RStudio** (recommended for development)

### Required R Packages

The recommended path is to restore dependencies with renv (below). If you need base tools first:

```r
install.packages(c("renv", "remotes", "devtools"))
```

## Setup

### 1. Clone and Navigate

```bash
cd ca-soil-health-reports
```

### 2. Initialize R Environment

```r
# Initialize renv for reproducible dependencies
renv::init()

# Restore packages (if renv.lock exists)
renv::restore()
```

### 3. Verify Quarto Installation

```r
# Check if Quarto is available
Sys.which("quarto")
```

If this returns an empty string, install Quarto from https://quarto.org/

### 4. Run the App

```r
# In RStudio: Open app.R and click "Run App"
# Or from R console:
shiny::runApp()
## Or from a terminal:
R -e "shiny::runApp()"
```

## Usage

### 8-Step Workflow

1. **Download Template**: Get the Excel template with detailed instructions
2. **Upload Data**: Upload your completed Excel template with soil health data
3. **Filter Data**: Select specific crops, soil types, or other variables to analyze
4. **Project Information**: Customize project name, producer name, and summary text
5. **Select Data**: Choose producer and year, and configure report options:
   - **Include regional comparisons**: When checked and your dataset contains multiple producers, reports show "Other Fields" data from other producers for comparison. When unchecked, only "Your Fields" data is shown and Project Average is calculated from your fields only. (Only relevant if your dataset contains multiple producers.)
   - **Include field maps**: When checked, reports include interactive maps and latitude/longitude tables. When unchecked, maps and location data are excluded.
6. **Select Grouping**: Choose how to group data (by field, treatment, or no grouping)
7. **Select Indicators**: Choose which soil health indicators to include
8. **Generate Report**: Create HTML or DOCX reports with your data

### Data Requirements

The app uses an Excel template with two sheets (downloadable at `files/soil-health-template.xlsx`):
- **Data**: Your soil health measurements
- **Data Dictionary**: Column definitions and metadata

### Required Columns
- `producer_id`: Producer/farm identifier
- `year`: Year of sampling (>= 2000)
- `sample_id`: Unique sample identifier
- `texture`: Soil texture classification

### Optional Columns
- `field_id`: Field identifier for grouping
- `treatment_id`: Treatment identifier for grouping
- `latitude`, `longitude`: For interactive maps
- Measurement columns: Physical, chemical, biological, and carbon indicators

### Data Validation
- **Quality assurance**: Non-numeric values in measurement columns are converted to missing with warnings; pre‑existing missing values are also reported
- **Required fields**: Missing values in required columns prevent progression
- **Grouping validation**: Only complete grouping variables are available for selection

### Privacy & Data
- Uploaded files are processed in-session and are not stored server-side. Remove sensitive data before sharing reports.

## Configuration

The app uses a configuration-backed approach for flexibility and maintainability.

### Filter Configuration

Edit `config/filter-config.csv` to customize which columns can be used for filtering:

```csv
column_name,filter_label,filter_type,required
crop,Crop,dropdown,FALSE
texture,Texture,dropdown,FALSE
site_type,Site Type,dropdown,FALSE
```

- **column_name**: The actual column name in your data
- **filter_label**: Display name for the filter dropdown
- **filter_type**: Type of filter (currently only "dropdown" supported)
- **required**: Whether this filter is required (TRUE/FALSE)

### Grouping Configuration

Edit `config/grouping_config.csv` to customize grouping options:

```csv
column_name,grouping_label,grouping_type,description
field_id,Field ID,dropdown,Group by different fields on the farm
treatment_id,Treatment ID,dropdown,Group by different treatments or management practices
```

### Required Fields Configuration

Edit `config/required-fields.csv` to customize data validation rules:

```csv
sheet,var,unique_by,required,data_type,description,validation_rule
Data,year,-,TRUE,integer,Year of sampling,>= 2000
Data,sample_id,sample_id,TRUE,character,Unique sample identifier,"no_duplicates,not_empty"
Data,producer_id,-,TRUE,character,Producer/farm identifier,not_empty
```
### Config-to-Module Map
- `config/filter-config.csv` → `R/modules/mod_data_filter.R`
- `config/grouping_config.csv` → `R/modules/mod_grouping.R`
- `config/required-fields.csv` → `R/utils/validation.R`
- `config/config.yml` → loaded in `global.R` via `R/logic/config.R`

## Development

### Project Structure

```
ca-soil-health-reports/
├── app.R                 # Main Shiny app
├── global.R             # Global setup and dependencies
├── config/
│   ├── filter-config.csv    # Filter configuration
│   ├── required-fields.csv  # Data validation rules
│   ├── measurement_groups.csv # Measurement group definitions
│   ├── grouping_config.csv  # Grouping variable options
│   └── config.yml           # App configuration
├── files/
│   └── soil-health-template.xlsx # Excel template
├── quarto/
│   ├── report_template.qmd  # Main report template
│   ├── inst/extdata/indicators.csv # Soil health indicators
│   └── styles.css          # Report styling
├── R/
│   ├── logic/           # Core processing & report-generation logic
│   ├── modules/         # Shiny modules (8-step workflow)
│   └── utils/           # Utility functions
├── www/                 # Static assets (CSS, JS, images)
└── renv.lock           # Package dependencies
```

### Adding New Features

1. **New Filters**: Add rows to `config/filter-config.csv` (no code changes needed)
2. **New Validation Rules**: Update `config/required-fields.csv`
3. **New Measurement Groups**: Update `config/measurement_groups.csv`
4. **New Grouping Options**: Update `config/grouping_config.csv`
5. **New Modules**: Create in `R/modules/`
6. **New Logic**: Add to `R/logic/`
7. **New Templates**: Add to `quarto/`

### Key files
- `R/helpers.R`: shared helpers (unique pulls, header helpers, summarize utilities)
- `R/tables.R`: flextable construction/styling and unit underline rules
- `R/utils/validation.R`: upload-time validation rules and checks
- `R/logic/config.R`: YAML config loader/utilities
- `R/logic/data.R`: load/clean/join-dictionary helpers
- `R/logic/wrapper.R`: report-generation wrapper
- `R/modules/mod_data_upload.R`: Excel upload + conversion and missing-value warnings
- `R/modules/mod_grouping.R`: grouping selection + diagnostics
- `R/modules/mod_data_filter.R`: filter UI (reads `config/filter-config.csv`)
- `R/modules/mod_build_reports.R`: build/download report step
- `R/modules/mod_about.R`: About page content

### Testing

```r
# Test individual functions
source("R/logic/wrapper.R")

# Test report generation
generate_soil_health_report(
  data_path = "files/soil-health-template.xlsx",
  producer_id = "Example Farm",
  year = 2024,
  output_dir = "outputs"
)
```

## Troubleshooting

### Common Issues

1. **"Quarto CLI is required"**
   - Install Quarto from https://quarto.org/
   - Ensure `quarto` is in your PATH

2. **"Missing required columns"**
   - Check your Excel file structure
   - Ensure both "Data" and "Data Dictionary" sheets exist
   - Verify required columns are present and non-empty

3. **"No grouping options available"**
   - Ensure `field_id` or `treatment_id` columns exist
   - Check that all records have values (no missing data)
   - Use "No grouping" option for farm-level comparisons

4. **"Non-numeric values converted to missing"**
   - Check measurement columns for text values
   - Ensure numeric columns contain only numbers
   - The `texture` column is excluded from this check

5. **Header mapping / Texture column issues**
   - If you see messages like `duplicated col_keys: Texture`, ensure Texture is only an ID column for Physical and not duplicated in header mapping. The app handles this automatically in current code.

6. **renv out of sync / Quarto warnings**
   - Run `renv::status()`; then `renv::snapshot()` (or `renv::restore()`), restart R, and re-run.

5. **Report generation fails**
   - Check data file format
   - Verify producer/year combinations exist
   - Check console for detailed error messages

### Performance Tips

- Reports are generated fresh each time (no caching)
- Close unused browser tabs to free memory
- Large datasets may take several minutes to process

## Deployment

The app is currently deployed to **ShinyApps.io** at:  
🔗 [https://maegensimmonds.shinyapps.io/ca-soil-health-reports/](https://maegensimmonds.shinyapps.io/ca-soil-health-reports/)

> **Note:** This deployment is temporarily hosted under the developer’s account and will be transferred to a UCANR institutional account for long-term maintenance.  
> The UC ANR-hosted version will serve as the official public instance.

### Deployment Process

Authorized maintainers can deploy to ShinyApps.io using:

```r
# Deploy to the authorized ShinyApps.io account
rsconnect::deployApp(appName = 'ca-soil-health-reports')
```
For collaborators or forks, you can deploy to your own account by changing the app name:
```r
# Example for personal or institutional deployment
rsconnect::deployApp(appName = 'my-ca-soil-health-reports')
```
Deployment requires an active ShinyApps.io account and credentials configured via:
```r
rsconnect::setAccountInfo(name = "<account>", token = "<token>", secret = "<secret>")
```
### Bundle Optimization

The app is optimized for deployment with:
- **File exclusions**: Large directories and unnecessary files are ignored
- **Dependency management**: Uses `renv` for reproducible package versions
- **Template system**: Excel templates and Quarto reports are included

## Contributing

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## License

This project is licensed under the [MIT License](LICENSE).

© 2025 Maegen Simmonds. Developed for UC Agriculture & Natural Resources. Maintained in collaboration with UCANR. 
See the [LICENSE](LICENSE) file for full terms and conditions.

## Citation

If you use this application in a publication, presentation, or report, please cite:

> Simmonds, M. B. (2025). *California Soil Health Reports Shiny App* (Version 1.0) [Computer software]. University of California Agriculture & Natural Resources. https://github.com/msimmond/ca-soil-health-reports

## Contact & Support

For technical support, troubleshooting, or questions about soil health interpretation and application use, please contact:

**Vivian Wauters**  
Project Scientist, UC Agriculture & Natural Resources  
📧 [vwauters@ucanr.edu](mailto:vwauters@ucanr.edu)  
🌐 [https://ucanr.edu](https://ucanr.edu)

## Acknowledgements

Developed by **Maegen Simmonds** in collaboration with:
- UC Agriculture and Natural Resources (UCANR)
- California Farm Demonstration Network (CFDN)

Supported by the **UC Climate Action Research Grants Program (Grant #R02CP6986)**.

### Additional acknowledgements
Portions of the data‑validation workflow and template design were adapted from the dirt‑data‑reports app. All adaptations were modified for California Soil Health workflows.
> Ryan, J.; Shapiro, T.; McIlquham, M.; Michel, L.; Potter, T.; Griffin LaHue, D.; Gelardi, D. Dirt Data Reports, 2025.  
> Live app: https://wsda.shinyapps.io/dirt-data-reports/  
> Source: https://github.com/WA-Department-of-Agriculture/dirt-data-reports

### Citation for adapted and reused functions from the `{soils}` package
Ryan JN, McIlquham M, Sarpong KA, Michel LM, Potter TS, Griffin LaHue D, Gelardi DL. (2024). Visualize and Report Soil Health Data with {soils}. Washington Soil Health Initiative.  
https://github.com/WA-Department-of-Agriculture/soils
