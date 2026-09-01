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
  log_info("reading config.yml")
  log_success("validated 12 parameters")
}

pipeline <- function() {
  log_step("Pipeline")
  load_config()
}

pipeline()

## -----------------------------------------------------------------------------
logtree_reset()

validate <- function(rows) {
  log_step("Validate")
  if (rows == 0) {
    log_warn("nothing to validate")
    return(invisible(NULL))       # early return: the step still closes
  }
  log_success("all rows valid")
}

check <- function() {
  log_step("Check")
  validate(0)
  validate(12)
}

check()

## -----------------------------------------------------------------------------
logtree_reset()

fetch <- function() {
  log_step("Fetch")
  log_debug("cache miss for key user:42")
  log_info("requesting from API")
  log_warn("rate limit at 80%")
  log_success("fetched 128 rows")
}

fetch()

## -----------------------------------------------------------------------------
logtree_reset()

parse_rows <- function() {
  log_step("Parse rows")
  log_info("1,200 rows")
  log_warn("coerced 3 rows to NA")
  log_success("parsed")            # does not undo the warning
}

parse_rows()

## -----------------------------------------------------------------------------
logtree_reset()

connect <- function() {
  log_step("Connect")
  log_error("primary unreachable (timeout after 5s)")
  log_info("failing over to replica")
  log_success("connected to replica")
  log_close(status = "success")    # override: we recovered
}

connect()

## ----error = TRUE-------------------------------------------------------------
try({
logtree_reset()

apply_migration <- function() {
  log_step("Apply migration")
  log_info("adding column users.tier")
  stop("constraint violation on users.email")
}

release <- function() {
  log_step("Release v2.1")
  apply_migration()
}

with_logging(release())
})

## -----------------------------------------------------------------------------
logtree_reset()

risky <- function() {
  log_step("Risky")
  stop("boom")
}

try(risky(), silent = TRUE)

## -----------------------------------------------------------------------------
logtree_reset()

noisy <- function() {
  log_step("Load data")
  message("using cached schema")
  warning("3 rows coerced to NA")
  log_info("1,200 rows")
}

with_logging(noisy(), summary = FALSE, warnings = TRUE)

## -----------------------------------------------------------------------------
logtree_reset()

id <- log_open("Import")
log_info("reading three files")
log_success("9,412 rows")
log_close(id)

## -----------------------------------------------------------------------------
logtree_reset()

id <- log_open("Publish")
log_success("pushed to production", close = TRUE)

## -----------------------------------------------------------------------------
logtree_reset()

load_file <- function(dataset, file) {
  log_step(file, group = dataset)
  log_info("reading rows")
  log_success("merged")
}

import_datasets <- function() {
  log_step("Import datasets")
  load_file("sales",   "2023.csv")
  load_file("sales",   "2024.csv")
  load_file("returns", "2024.csv")
}

import_datasets()

## -----------------------------------------------------------------------------
logtree_reset()

fetch_verbose <- function() {
  log_step("Fetch")
  log_debug("cache miss for key user:42")
  log_info("connecting to API")
  log_success("fetched 12 records")
}

fetch_verbose()                  # default: the debug line is hidden

logtree_threshold("debug")
fetch_verbose()                  # raised: it appears

logtree_threshold("info")

## -----------------------------------------------------------------------------
logtree_reset()

migrate <- function() {
  log_step("Apply migration")
  log_warn("table lock held 800ms")
  log_error("constraint violation on users.email")
}

smoke_test <- function() {
  log_step("Smoke test")
  log_success("all endpoints 200")
}

release <- function() {
  log_step("Release v2.1")
  migrate()
  smoke_test()
}

with_logging(release(), summary = FALSE)
logtree_summary()

## -----------------------------------------------------------------------------
logtree_summary(filter = "error", depth = 1)

## -----------------------------------------------------------------------------
logtree_reset()
logtree_theme(list(trace = list(show = "problems", format = "{fn}()")))

flaky <- function() {
  log_step("Parse rows")
  log_info("1,200 rows")
  log_warn("coerced 3 rows")
}

flaky()
logtree_theme("unicode")

## -----------------------------------------------------------------------------
logtree_reset()
logtree_theme(list(timestamp = list(format = "%H:%M:%S")))
pipeline()
logtree_theme(list(timestamp = list(format = NULL)))

## -----------------------------------------------------------------------------
logtree_theme("ascii")
pipeline()

logtree_theme("ci")
pipeline()

logtree_theme("unicode")

## -----------------------------------------------------------------------------
logtree_theme("unicode", overrides = list(
  success = list(glyph = "*", color = c("green", "bold")),
  done    = list(text = "{label} ok")
))
pipeline()
logtree_theme("unicode")

## -----------------------------------------------------------------------------
logtree_theme("unicode", compact = "tight", glyph_gap = 0)
pipeline()
logtree_theme("unicode")

## -----------------------------------------------------------------------------
logtree_theme("unicode", wrap = 56)

long <- function() {
  log_step("Deploy")
  log_info("uploading layers to registry.example.internal, 412 MB across 14 layers")
}
long()

logtree_theme("unicode")

## -----------------------------------------------------------------------------
log_path <- tempfile(fileext = ".log")
handle <- logtree_sink_file(log_path, format = "text")

logtree_reset()
pipeline()

writeLines(readLines(log_path))

## -----------------------------------------------------------------------------
logtree_sinks()
logtree_sink_remove(handle)
logtree_sinks()

## -----------------------------------------------------------------------------
kinds <- character(0)
h <- logtree_sink(function(event) kinds <<- c(kinds, event$kind))

logtree_reset()
pipeline()
table(kinds)

logtree_sink_remove(h)

## -----------------------------------------------------------------------------
verbose_path <- tempfile(fileext = ".log")
h <- logtree_sink_file(verbose_path, format = "text", threshold = "debug")

logtree_reset()
fetch_verbose()          # console: no debug line

writeLines(readLines(verbose_path))   # file: it is there
logtree_sink_remove(h)

## -----------------------------------------------------------------------------
h <- logtree_sink_memory()

logtree_reset()
pipeline()

events <- logtree_sink_memory_events(h)
events[, c("level", "depth", "label", "status")]

logtree_sink_remove(h)

## -----------------------------------------------------------------------------
was <- logtree_mute()

logtree_reset()
pipeline()          # prints nothing

logtree_unmute()
length(logtree_summary())

## ----eval = rlang::is_installed("logger", version = "0.3.0")------------------
logtree_reset()
logtree_threshold("debug")

ns <- "my_app"
logtree_logger(namespace = ns)

process_data <- function() {
  log_step("Processing data")
  logger::log_info("reading input file", namespace = ns)
  logger::log_debug("parsed 5,000 rows", namespace = ns)
  logger::log_success("transformation complete", namespace = ns)
}

process_data()
logtree_threshold("info")

