#' Initialize a stageRunner object.
#'
#' stageRunner objects are used for executing a linear sequence of
#' actions on a context (an environment). For example, if we have an
#' environment \code{e} containing \code{x = 1, y = 2}, then using
#' \code{stages = list(function(e) e$x <- e$x + 1, function(e) e$y <- e$y - e$x)}
#' will cause \code{x = 2, y = 0} after running the stages.
#'
#' @param context an environment. The initial environment that is getting
#'    modified during the execution of the stages. 
#' @param stages a list. The functions to execute on the \code{context}.
#' @param remember a logical. Whether to keep a copy of the context and its
#'    contents throughout each stage for debugging purposes--this makes it
#'    easy to go back and investigate a stage. This could be optimized by
#'    developing a package for "diffing" two environments. The default is
#'    \code{FALSE}.
stageRunner__initialize <- function(context, stages, remember = FALSE) {
  context <<- context
  stages <<- stages
  stopifnot(all(vapply(stages,
    function(s) is.function(s) || is.stagerunner(s), logical(1))))

  if (any(violators <- grepl('/', names(stages)))) {
    msg <- paste0("Stage names may not have a '/' character. The following do not ",
      "satisfy this constraint: '",
      paste0(names(stages)[violators], collapse = "', '"), "'")
    stop(msg)
  }

  remember <<- remember
}

#' Run the stages in a stageRunner object.
#'
#' @param stage_key an indexing parameter. Many forms are accepted, but the
#'   easiest is the name of the stage. For example, if we have
#'   \code{stageRunner$new(context, list(stage_one = some_fn, stage_two = some_other_fn))}
#'   then using \code{run('stage_one')} will execute \code{some_fn}.
#'   Additional indexing forms are logical (which stages to execute),
#'   numeric (which stages to execute by indices), negative (all but the
#'   given stages), character (as above), and nested forms of these.
#'   The latter refers to instances of the following:
#'   \code{stageRunner$new(context, list(stage_one =
#'     stageRunner$new(context, substage_one = some_fn, substage_two = other_fn),
#'     stage_two = another_fn))}.
#'   Here, the following all execute only substage_two:
#'   \code{run(list(list(FALSE, TRUE), FALSE))},
#'   \code{run(list(list(1, 2)))},
#'   \code{run('stage_one/substage_two')},
#'   \code{run('one/two')},
#'   \code{run(list(list('one', 'two')))},
#'   \code{run(list(list('one', 2)))}
#'   Notice that regular expressions are allowed for characters.
#'   The default is \code{NULL}, which runs the whole sequences of stages.
#' @param normalized logical. A convenience recursion performance helper. If
#'   \code{TRUE}, stageRunner will assume the \code{stage_key} argument is a
#'   nested list of logicals.
stageRunner__run <- function(stage_key = NULL, normalized = FALSE) {
  if (identical(normalized, FALSE))
    stage_key <- normalize_stage_keys(stage_key, stages)

  # Now that we have determined which stages to run, cycle through them all.
  # It is up to the user to determine that context changes make sense.
  # We also implicitly sort the stages to ensure linearity is preserved.
  # Stagerunner enforces the linearity and directionality set in the stage definitions.
  
  lapply(seq_along(stage_key), function(stage_index) 
    if (identical(stage_key[[stage_index]], TRUE)) {
      stage <- stages[[stage_index]]
      if (is.stagerunner(stage)) stage$run() else stage(context)
    } else if (is.list(stage_key[[stage_index]])) {
      if (!is.stagerunner(stages[[stage_index]]))
        stop("Invalid stage key: attempted to make a nested stage reference ",
             "to a non-existent stage")
      stages[[stage_index]]$run(stage_key[[stage_index]])
    }
  )
  TRUE
}

#' Stage runner is a reference class for parametrizing and executing
#' a linear sequence of actions.
#' 
#' @docType class 
#' @export
#' @name stageRunner
stageRunner <- setRefClass('stageRunner',
  fields = list(context = 'environment', stages = 'list', remember = 'logical'),
  methods = list(
    initialize = stagerunner:::stageRunner__initialize,
    run        = stagerunner:::stageRunner__run
  )
)

#' @name stageRunner
#' @export
NULL

#' Check whether an R object is a stageRunner object
#'
#' @export
#' @param obj any object. \code{TRUE} if the object is of class
#'    \code{stageRunner}, \code{FALSE} otherwise.
is.stagerunner <- function(obj) inherits(obj, 'stageRunner')

