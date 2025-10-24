# California Soil Health Reports Shiny App

A comprehensive Shiny application for generating soil health reports for California agricultural producers. The app provides an 8-step workflow for data upload, filtering, analysis, and report generation using integrated soil health functions and Quarto templates.

## Features

- **8-step workflow**: Guided process from data upload to report generation
- **Data filtering**: Filter by crop, soil type, and other variables with cross-filtering
- **Quality assurance**: Comprehensive data validation with user-friendly error messages
- **Grouping options**: Compare different fields or treatments with validation
- **Interactive previews**: Real-time data preview and validation feedback
- **Multiple outputs**: HTML and DOCX report formats
- **Template system**: Excel template with detailed instructions and column guide

## Prerequisites

### Required Software

1. **R** (version 4.0 or higher)
2. **Quarto CLI** - Install from https://quarto.org/
3. **RStudio** (recommended for development)

### Required R Packages

The app will automatically install most dependencies, but you may need:

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
```

## Usage

### 8-Step Workflow

1. **Download Template**: Get the Excel template with detailed instructions
2. **Upload Data**: Upload your completed Excel template with soil health data
3. **Filter Data**: Select specific crops, soil types, or other variables to analyze
4. **Select Producer**: Choose the producer from the dropdown
5. **Select Year**: Choose the year for analysis
6. **Select Grouping**: Choose how to group data (by field, treatment, or no grouping)
7. **Select Indicators**: Choose which soil health indicators to include
8. **Generate Report**: Create HTML or DOCX reports with your data

### Data Requirements

The app uses an Excel template with two sheets:
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
- **Quality assurance**: Non-numeric values in measurement columns are converted to missing with warnings
- **Required fields**: Missing values in required columns prevent progression
- **Grouping validation**: Only complete grouping variables are available for selection

## Configuration

The app uses a configuration-based approach for flexibility and maintainability.

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

## Development

### Project Structure

```
ca-soil-health-reports-clean/
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
│   ├── logic/           # Core business logic
│   ├── modules/         # Shiny modules (8-step workflow)
│   └── utils/           # Utility functions
├── www/                 # Static assets (CSS, JS, images)
└── renv.lock           # Package dependencies
```

### Adding New Features

1. **New Filters**: Add rows to `config/filter-config.csv` (no code changes needed!)
2. **New Validation Rules**: Update `config/required-fields.csv`
3. **New Measurement Groups**: Update `config/measurement_groups.csv`
4. **New Grouping Options**: Update `config/grouping_config.csv`
5. **New Modules**: Create in `R/modules/`
6. **New Logic**: Add to `R/logic/`
7. **New Templates**: Add to `quarto/`

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

5. **Report generation fails**
   - Check data file format
   - Verify producer/year combinations exist
   - Check console for detailed error messages

### Performance Tips

- Reports are generated fresh each time (no caching)
- Close unused browser tabs to free memory
- Large datasets may take several minutes to process

## Deployment

The app is deployed to ShinyApps.io at: https://maegensimmonds.shinyapps.io/ca-soil-health-reports/

### Deployment Process

```r
# Deploy to ShinyApps.io
rsconnect::deployApp(appName = 'ca-soil-health-reports')
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

TBD

## Credits

Developed by **Maegen Simmonds** in collaboration with:
- UC Agriculture and Natural Resources (UCANR)
- California Farm Demonstration Network (CFDN)

Supported by the **Climate Action Research Grants Program of the University of California, Grant # R02CP6986**.

The soil health reporting functions build on and reuse functions originally developed in the {soils} package, created by the Washington State Department of Agriculture and Washington State University as part of the Washington Soil Health Initiative (WASHI).
