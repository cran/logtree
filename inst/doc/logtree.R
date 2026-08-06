## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(logtree)

## -----------------------------------------------------------------------------
logtree_reset()

load_config <- function() {
  log_step("Load config")
  log_info("Reading config.yml")
  log_success("Validated 12 parameters")
}

pipeline <- function() {
  log_step("Pipeline")
  load_config()
}

pipeline()

## -----------------------------------------------------------------------------
logtree_reset()

fetch_articles <- function() {
  log_step("Fetching articles")
  log_info("Connecting to API")
  log_warn("Retry 1/3 due to timeout")
  log_success("Fetched 1,204 articles")
}

fetch_articles()

## -----------------------------------------------------------------------------
logtree_reset()

run_classifier <- function() {
  with_logging({
    log_step("Classifying")
    stop("model timeout after 30s")
  })
}

tryCatch(run_classifier(), error = function(e) invisible(NULL))

## -----------------------------------------------------------------------------
logtree_reset()

risky <- function() {
  log_step("risky")
  stop("boom")
}

tryCatch(risky(), error = function(e) invisible(NULL))

## -----------------------------------------------------------------------------
logtree_reset()

load_file <- function(dataset, file) {
  log_step(file, group = dataset)
  log_info("Reading rows")
  log_success("Merged into dataset")
}

import_datasets <- function() {
  log_step("Import datasets")
  load_file("sales",   "2023.csv")
  load_file("sales",   "2024.csv")
  load_file("returns", "2024.csv")
}

import_datasets()

## -----------------------------------------------------------------------------
logtree_theme("ascii")
pipeline()

logtree_theme("unicode")

## -----------------------------------------------------------------------------
logtree_theme("unicode", overrides = list(
  success = list(glyph = "*", color = c("green", "bold")),
  group   = list(bracket = TRUE)
))
pipeline()
logtree_theme("unicode")

## -----------------------------------------------------------------------------
log_path <- tempfile(fileext = ".log")
logtree_sink_file(log_path, format = "text")

logtree_reset()
pipeline()

writeLines(readLines(log_path))

## -----------------------------------------------------------------------------
logtree_threshold("warn")
fetch_articles()
logtree_threshold("info")

## -----------------------------------------------------------------------------
logtree_reset()

fetch_verbose <- function() {
  log_step("Fetching")
  log_debug("cache miss for key user:42")
  log_info("connecting to API")
  log_debug("request took 84ms")
  log_success("fetched 12 records")
}

# At default verbosity, debug lines are hidden
fetch_verbose()

# Raise verbosity to show debug lines
logtree_threshold("debug")
logtree_reset()
fetch_verbose()

logtree_threshold("info")

## ----eval = requireNamespace("logger", quietly = TRUE)------------------------
logtree_reset()
logtree_threshold("debug")  # the only gate, now that logtree_logger() opened logger's

ns <- "my_app"
logtree_logger(namespace = ns)

process_data <- function() {
  log_step("Processing data")
  logger::log_info("reading input file", namespace = ns)
  logger::log_debug("parsed 5,000 rows", namespace = ns)
  logger::log_success("transformation complete", namespace = ns)
}

process_data()

