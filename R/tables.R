#' Conditional formatting of flextable background cell colors
#'
#' Color the background cells based on how the value compares to the project
#' average. The project average must be the last row of the table. A footnote is
#' added to the table describing what the dark and light colors mean.
#'
#' @param ft Flextable object
#' @param lighter_color Lighter background color. Defaults to WaSHI cream.
#' @param darker_color Darker background color. Defaults to WaSHI tan.
#' @param language Language of the footnote. "English" (default) or "Spanish".
#'
#' @export
#'
#' @examples
#' # Read in wrangled example table data
#' tables_path <- soils_example("tables.RDS")
#' tables <- readRDS(tables_path)
#'
#' # Make the table
#' ft <- flextable::flextable(tables$biological)
#' ft
#'
#' # Conditionally format background cell colors
#' format_ft_colors(ft)
format_ft_colors <- function(
  ft,
  lighter_color = "#F2F0E6",
  darker_color = "#ccc29c",
  language = "English"
) {
  # Language arg must be "English" or "Spanish"
  rlang::arg_match(
    arg = language,
    values = c("English", "Spanish")
  )

  # Header: solid color with white text
  ft <- flextable::bg(ft, part = "header", bg = darker_color)
  ft <- flextable::color(ft, part = "header", color = "white")

  # Body: conditional formatting based on values compared to project average
  # The project average should be the last row
  data <- ft$body$dataset
  n_rows <- nrow(data)
  
  # Get numeric columns (exclude first column which is usually "Field or Average")
  numeric_cols <- which(sapply(data, is.numeric))
  
  if (n_rows > 1 && length(numeric_cols) > 0) {
    # Project average is the last row
    project_avg_row <- n_rows
    
    for (j in numeric_cols) {
      # Get project average for this column
      project_avg <- data[project_avg_row, j]
      
      if (!is.na(project_avg) && is.numeric(project_avg)) {
        # Compare each value to project average
        for (i in 1:(n_rows - 1)) {  # Exclude project average row
          value <- data[i, j]
          if (!is.na(value) && is.numeric(value)) {
            if (value >= project_avg) {
              ft <- flextable::bg(ft, i = i, j = j, part = "body", bg = darker_color)
            } else {
              ft <- flextable::bg(ft, i = i, j = j, part = "body", bg = lighter_color)
            }
          }
        }
      }
    }
  } else {
    # Fallback: set all body cells to lighter color
    ft <- flextable::bg(ft, part = "body", bg = lighter_color)
  }

  # Center align all columns
  ft <- flextable::align(ft, align = "center", part = "all")

  # Add an empty footer line
  ft <- flextable::add_footer_lines(ft, values = "")

  # English footnote
  # Add the footnote content, with the backgrounds highlighted
  if (language == "English") {
    ft <- flextable::compose(
      ft,
      i = 1,
      j = 1,
      part = "footer",
      value = flextable::as_paragraph(
        "Values greater than or equal to project average have ",
        flextable::as_highlight(
          "darker backgrounds. \n",
          darker_color
        ),
        "Values less than project average have ",
        flextable::as_highlight(
          "lighter backgrounds. ",
          lighter_color
        )
      )
    )
  }

  # Spanish footnote
  # Add the footnote content, with the backgrounds highlighted
  if (language == "Spanish") {
    ft <- flextable::compose(
      ft,
      i = 1,
      j = 1,
      part = "footer",
      value = flextable::as_paragraph(
        "Valores \U2265 promedio de proyectos tienen ",
        flextable::as_highlight(
          "fondos m\u00e1s oscuros. \n",
          darker_color
        ),
        "Valores < promedio de proyectos tienen ",
        flextable::as_highlight(
          "fondos m\u00e1s claros ",
          lighter_color
        )
      )
    )
  }
  return(ft)
}

#' Style a flextable
#'
#' @param ft Flextable object.
#' @param header_font Font of header text. Defaults to `"Lato"`.
#' @param body_font Font of body text. Defaults to `"Poppins"`.
#' @param header_color Background color of header cells. Defaults to WaSHI
#'   green.
#' @param header_text_color Color of header text. Defaults to white.
#' @param border_color Color of border lines. Defaults to WaSHI gray.
#'
#' @returns Styled flextable object.
#'
#' @export
#'
#' @examples
#' # Read in wrangled example table data
#' tables_path <- soils_example("tables.RDS")
#' tables <- readRDS(tables_path)
#'
#' # Make the table
#' ft <- flextable::flextable(tables$biological)
#' ft
#'
#' # Style the table
#' style_ft(ft)
style_ft <- function(
  ft,
  header_font = "Georgia",
  body_font = "Helvetica",
  header_color = "#023B2C",
  header_text_color = "white",
  border_color = "#3E3D3D"
) {
  flextable::set_flextable_defaults(
    font.family = body_font,
    font.size = 10
  )

  header_cell <- officer::fp_cell(
    background.color = header_color
  )
  header_text <- officer::fp_text(
    font.family = header_font,
    font.size = 11,
    bold = TRUE,
    color = header_text_color
  )

  ft <- flextable::style(
    ft,
    pr_t = header_text,
    pr_c = header_cell,
    part = "header"
  ) |>
    flextable::bold(j = 1, bold = TRUE, part = "body") |>
    flextable::hline(
      border = officer::fp_border(
        color = border_color
      ),
      part = "body"
    ) |>
    flextable::align(align = "center", part = "header") |>
    flextable::line_spacing(space = 1.3, part = "all")

  return(ft)
}

#' Add bottom border to specific columns in flextable
#'
#' Use when columns with the same units are merged together to add a bottom
#' border to make it more obvious those columns share units.
#'
#' @param ft flextable object
#' @inheritParams make_ft
#'
#' @returns Flextable object with bottom borders added.
#' @export
#'
#' @examples
#' # Read in wrangled table data
#' headers_path <- soils_example("headers.RDS")
#' headers <- readRDS(headers_path)
#'
#' tables_path <- soils_example("tables.RDS")
#' tables <- readRDS(tables_path)
#'
#' # Input dataframes
#' headers$chemical
#'
#' tables$chemical
#'
#' # Make the flextable
#' make_ft(
#'   table = tables$chemical,
#'   header = headers$chemical
#' ) |>
#'   # Style the flextable
#'   style_ft() |>
#'   # Add the white line under the columns with the same units
#'   unit_hline(header = headers$chemical)
#'
#' # Example without `unit_hline()`
#' make_ft(
#'   table = tables$chemical,
#'   header = headers$chemical
#' ) |>
#'   # Style the flextable
#'   style_ft()
unit_hline <- function(ft, header) {
  if (is.null(header) || nrow(header) == 0L) return(ft)
  if (!"unit" %in% names(header) || !"key" %in% names(header)) return(ft)

  # Normalize units and identify measurement (non-ID) columns
  header <- header |>
    dplyr::mutate(unit = ifelse(is.na(unit), "", unit))

  id_keys  <- c("Field or Average", "Texture")
  is_meas  <- !header$key %in% id_keys

  # Duplicate unit groups among measurement columns only, excluding blanks
  dup_mask <- (duplicated(header$unit) | duplicated(header$unit, fromLast = TRUE)) &
              header$unit != "" & is_meas

  j <- which(dup_mask)

  if (!length(j)) return(ft)

  ft |>
    flextable::merge_h(part = "header") |>
    flextable::hline(
      i = 1, j = j, part = "header",
      border = officer::fp_border(color = "white")
    )
}

#' Make a flextable with column names from another dataframe
#'
#' @param table A dataframe with the contents of the desired flextable output.
#' @param header Another dataframe with three columns:
#'  * First column contains what the top header row should be. In our template,
#'  this is the abbreviation of the measurement (i.e. `Organic Matter`).
#'  * Second column, called `"key"`, contains the join key. In our template,
#'  this is the same as the first column.
#' * Third column contains the second header row. In our template, this is
#' the unit (i.e. `%`).
#'
#' @export
#' @returns Formatted flextable object.
#'
#' @examples
#' # Read in wrangled table data
#' headers_path <- soils_example("headers.RDS")
#' headers <- readRDS(headers_path)
#'
#' tables_path <- soils_example("tables.RDS")
#' tables <- readRDS(tables_path)
#'
#' # Input dataframes
#' headers$chemical
#'
#' tables$chemical
#'
#' # Make the flextable
#' make_ft(
#'   table = tables$chemical,
#'   header = headers$chemical
#' ) |>
#'   # Style the flextable
#'   style_ft() |>
#'   # Add the white line under the columns with the same units
#'   unit_hline(header = headers$chemical)
#'
make_ft <- function(table, header) {
  flextable::flextable(table) |>
    flextable::set_header_df(mapping = header, key = "key")
}
