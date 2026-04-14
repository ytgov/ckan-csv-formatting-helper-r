source("lib/helpers.R")

run_start_time <- now()
add_log_entry("Start time was: ", run_start_time)

# Convert all the CSV and Excel files in subdirectories of input/
convert_all_files()



run_end_time <- now()
run_elapsed_hours <- round(time_length(interval(run_start_time, run_end_time), "minutes"), digits = 2)

add_log_entry("End time was: ", run_end_time)
add_log_entry("Elapsed time was: ", run_elapsed_hours, " minutes")

# Write the log files to CSV:
run_log |> 
  write_csv("run_log.csv")

