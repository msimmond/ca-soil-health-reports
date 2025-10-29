#' Pull unique values from one column of dataframe
#'
#' @param df Dataframe with column to extract unique values from.
#' @param target Variable to pull unique vector of (i.e. crop or
#'   county).
#'
#' @returns Vector of unique values from target column.
#' @examples
#' washi_data |>
#'   pull_unique(target = crop)
#'
#' @export
#'
pull_unique <- function(df, target) {
  unique(df[[target]])
}

#' Summarize by project
#'
#' @param results_long Long format dataframe with soil health results.
#' @param dictionary Data dictionary with measurement information.
#'
#' @returns Dataframe with project-level summaries.
#' @export
#'
summarize_by_project <- function(results_long, dictionary) {
  results_long |>
    dplyr::summarize(
      Texture = calculate_mode(texture),
      .by = measurement_group
    )
}

#' Summarize by variable
#'
#' @param results_long Long format dataframe with soil health results.
#' @param dictionary Data dictionary with measurement information.
#' @param var Optional grouping variable to summarize by.
#'
#' @returns Dataframe with variable-level summaries.
#' @export
#'
summarize_by_var <- function(results_long, dictionary, var = NULL) {
  if (!is.null(var) && var %in% names(results_long)) {
    results_long |>
      dplyr::summarize(
        value = mean(value, na.rm = TRUE),
        .by = c(measurement, measurement_group, .data[[var]])
      )
  } else {
    results_long |>
      dplyr::summarize(
        value = mean(value, na.rm = TRUE),
        .by = c(measurement, measurement_group)
      )
  }
}

# Helper function for mode calculation (internal use)
calculate_mode <- function(x) {
  uniqx <- unique(stats::na.omit(x))
  uniqx[which.max(tabulate(match(x, uniqx)))]
}

#' Get table headers for a measurement group
#'
#' @param dictionary Data dictionary with measurement information
#' @param group Measurement group name
#' @returns List of headers for the measurement group
#' @export
#'
get_table_headers <- function(dictionary, group) {
  if (is.null(dictionary) || nrow(dictionary) == 0) {
    stop("Dictionary is null or empty")
  }
  
  if (!"measurement_group" %in% names(dictionary)) {
    stop("Dictionary missing 'measurement_group' column. Available columns: ", paste(names(dictionary), collapse = ", "))
  }
  
  # Filter dictionary for the specific measurement group
  group_data <- dictionary[dictionary$measurement_group == group, ]
  
  if (nrow(group_data) == 0) {
    available_groups <- unique(dictionary$measurement_group)
    stop("No data found for group '", group, "'. Available groups: ", paste(available_groups, collapse = ", "))
  }
  
  # Check if required columns exist
  required_cols <- c("abbr", "unit")
  missing_cols <- setdiff(required_cols, names(group_data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns in dictionary: ", paste(missing_cols, collapse = ", "))
  }
  
  # Return data frame matching ca-soils structure: abbr, key, unit
  # The first column should be the header text (abbr), second is key for matching, third is unit
  group_data |>
    dplyr::transmute(
      abbr = as.character(abbr),
      key  = as.character(abbr),
      unit = as.character(unit)
    ) |>
    # include the first (ID) column mapping
    rbind(data.frame(
      abbr = "Field or Average",
      key  = "Field or Average",
      unit = "",
      stringsAsFactors = FALSE
    ))
}
