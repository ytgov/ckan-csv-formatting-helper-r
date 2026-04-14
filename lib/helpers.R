library(tidyverse)
library(jsonlite)
library(readxl)
library(fs)
library(lubridate)
library(janitor)


# Logging helper ----------------------------------------------------------

run_log <- tribble(
  ~time, ~message
)

# Logging helper function
add_log_entry <- function(...) {
  
  log_text <- str_c(...)
  
  new_row = tibble_row(
    time = now(),
    message = log_text
  )
  
  run_log <<- run_log |>
    bind_rows(
      new_row
    )
  
  cat(log_text, "\n")
}


# File finding and converting ---------------------------------------------

find_input_directories <- function() {
  
  input_directories <- dir_ls("input", type = "directory")
  
  input_directories
  
}

# For Excel files, replace the output file extension with .csv
# And convert output filepaths to lowercase (kebab-case)
format_csv_filename <- function(filepath) {
  
  filepath <- path(
    path_dir(filepath),
    str_c(str_to_kebab(path_ext_remove(path_file(filepath))), ".csv")
  )
  
  filepath
  
}

format_spreadsheet_data_to_csv <- function(filepath, spreadsheet_data) {
  
  # Switch from the (leading) input/ directory to the corresponding output directory
  output_filepath <- str_replace(filepath, "^input/", "output/")
  
  output_filepath <- format_csv_filename(output_filepath)
  
  # Create a corresponding output directory if it doesn't already exist
  dir_create(path_dir(output_filepath))
  
  add_log_entry("Converting and saving: ", filepath)
  
  spreadsheet_data |> 
    clean_names() |> 
    write_csv(output_filepath, na = "")
  
}

load_csv_or_excel_file <- function(filepath) {
  
  file_extension <- path_ext(filepath)
  
  if(file_extension == "csv") {
    
    spreadsheet_data <- read_csv(filepath)
    
  }
  else if(file_extension == "xls" || file_extension == "xlsx") {
    
    spreadsheet_data <- read_excel(filepath)
    
  }
  else {
    cat("Not a valid file")
  }
  
  spreadsheet_data
  
}

convert_csv_or_excel_file <- function(filepath) {
  
  
  format_spreadsheet_data_to_csv(
    filepath,
    load_csv_or_excel_file(filepath)
    )
   
}

convert_all_csv_or_excel_files_in_directory <- function(input_directory) {
  
  csv_or_excel_files <- dir_ls(input_directory, type = "file", regexp = "^.*\\.(csv|xls|xlsx)$")
  
  map(csv_or_excel_files, convert_csv_or_excel_file)
  
}

convert_all_files <- function() {
  
  map(find_input_directories(), convert_all_csv_or_excel_files_in_directory)
  
}
