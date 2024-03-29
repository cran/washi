#' Create standard WaSHI plots
#'
#' All changed defaults from this function can be overridden by another
#' call to [ggplot2::theme()] with the desired changes.
#'
#' @source Adapted from `glitr::si_style()`.
#'
#' @param header_font Font family for title and subtitle. Defaults to
#'   "Lato Black".
#' @param header_color Font color for title and subtitle. Defaults to
#'   almost black.
#' @param body_font Font family for all other text Defaults to
#'   "Poppins".
#' @param body_color Font color for all other text Defaults to almost
#'   black.
#' @param text_scale Scalar that will grow/shrink all text defined
#'   within.
#' @param legend_position Position of legend ("none", "left", "right",
#'   "bottom", "top", or two-element numeric vector). Defaults to
#'   "top".
#' @param facet_space Controls how far apart facets are from each
#'   other.
#' @param color_gridline Gridline color. Defaults to WaSHI tan.
#' @param gridline_x Boolean indicating whether major gridlines are
#'   displayed for the x axis. Default is TRUE.
#' @param gridline_y Boolean indicating whether major gridlines are
#'   displayed for the y axis. Default is TRUE.
#' @param ... Pass any parameters from theme that are not already
#'   defined within.
#'
#' @importFrom ggplot2 %+replace%
#' @returns `ggplot2` object
#' @family ggplot2 functions
#'
#' @examples
#' # NOTE: These examples do not use Poppins or Lato in order to pass
#' # automated checks on computers without these fonts installed.
#'
#' library(ggplot2)
#'
#' # Single geom_point plot
#' example_data_wide |>
#'   subset(crop %in% c("Apple", "Cherry", "Potato")) |>
#'   ggplot(aes(x = pH, y = Mn_mg.kg, color = crop)) +
#'   labs(
#'     title = "Scatter plot of pH and Mn (mg/kg)",
#'     subtitle = "Example with geom_point().",
#'     caption = "This is a caption."
#'   ) +
#'   geom_point(size = 2.5) +
#'   washi_theme(
#'     header_font = "sans",
#'     body_font = "sans"
#'   ) +
#'   washi_scale()
#'
#' # Bar plot
#' if (requireNamespace("forcats")) {
#'   example_data_wide |>
#'     ggplot(aes(x = forcats::fct_rev(forcats::fct_infreq(crop)))) +
#'     geom_bar(fill = washi_pal[["standard"]][["blue"]]) +
#'     geom_text(
#'       aes(
#'         y = after_stat(count),
#'         label = after_stat(count)
#'       ),
#'       stat = "count",
#'       hjust = 2.5,
#'       color = "white"
#'     ) +
#'     # Flip coordinates to accommodate long crop names
#'     coord_flip() +
#'     labs(
#'       title = "Number of samples in each crop",
#'       subtitle = "Example plot with geom_bar() without gridlines.",
#'       y = NULL,
#'       x = NULL
#'     ) +
#'     # Turn gridlines off
#'     washi_theme(
#'       gridline_y = FALSE,
#'       gridline_x = FALSE,
#'       header_font = "sans",
#'       body_font = "sans"
#'     ) +
#'     # Remove x-axis
#'     theme(axis.text.x = element_blank())
#' }
#'
#' # Facetted geom_density plots
#' example_data_long |>
#'   subset(measurement %in% c("totalC_%", "poxC_mg.kg") &
#'     !texture == "Loamy Sand") |>
#'   ggplot(aes(x = value, fill = texture, color = texture)) +
#'   labs(
#'     title = "Distribution of POXC (mg/kg) and Total C (%)",
#'     subtitle = "Example with geom_density() and facet_wrap()."
#'   ) +
#'   geom_density(alpha = 0.4) +
#'   facet_wrap(. ~ measurement, scales = "free") +
#'   washi_theme(
#'     legend_position = "bottom",
#'     header_font = "sans",
#'     body_font = "sans"
#'   ) +
#'   washi_scale() +
#'   xlab(NULL) +
#'   guides(col = guide_legend(nrow = 2, byrow = TRUE))
#' @export
washi_theme <- function(
  header_font = "Lato Black",
  header_color = "#151414",
  body_font = "Poppins",
  body_color = "#151414",
  text_scale = 1,
  legend_position = "top",
  facet_space = 2,
  color_gridline = washi_pal[["standard"]][["tan"]],
  gridline_y = TRUE,
  gridline_x = TRUE,
  ...
    ) {
  # Change font to "sans" if given font isn't found
  check_fonts(
    header_font = header_font,
    body_font = body_font
  )

  # Errors for invalid legend_position argument
  if (length(legend_position) > 1) {
    cli::cli_abort("`legend_position` must have length 1.")
  }

  legend_choices <- c("top", "bottom", "left", "right", "none")

  if (!legend_position %in% legend_choices) {
    cli::cli_abort("`legend_position` must be one of {dQuote(legend_choices)}.")
  }

  # Errors if invalid gridline argument
  if (!is.logical(gridline_y)) {
    cli::cli_abort("`gridline_y` must be TRUE or FALSE.")
  }

  if (!is.logical(gridline_x)) {
    cli::cli_abort("`gridline_x` must be TRUE or FALSE.")
  }

  # Set up gridline variables

  gridline_y <- if (isTRUE(gridline_y)) {
    ggplot2::element_line(
      color = color_gridline,
      linewidth = 0.25
    )
  } else {
    ggplot2::element_blank()
  }

  gridline_x <- if (isTRUE(gridline_x)) {
    ggplot2::element_line(
      color = color_gridline,
      linewidth = 0.25
    )
  } else {
    ggplot2::element_blank()
  }

  # Set up theme based on theme_minimal

  ggplot2::theme_minimal() %+replace%

    ggplot2::theme(
      plot.title = ggplot2::element_text(
        family = header_font,
        size = 14 * text_scale,
        face = "bold",
        color = header_color,
        margin = ggplot2::margin(b = 6),
        hjust = 0
      ),

      # This sets the font, size, type and color of text for the
      # chart's subtitle, as well as setting a margin between the
      # title and the subtitle
      plot.subtitle = ggplot2::element_text(
        family = header_font,
        size = 12 * text_scale,
        face = "bold",
        color = header_color,
        margin = ggplot2::margin(b = 15),
        hjust = 0
      ),
      plot.caption = ggplot2::element_text(
        family = body_font,
        size = 9 * text_scale,
        color = body_color,
        margin = ggplot2::margin(t = 6),
        hjust = 1,
        vjust = 1
      ),
      plot.margin = ggplot2::margin(t = 15, r = 15, b = 10, l = 15),
      plot.title.position = "plot", # Move plot.title to the left
      plot.caption.position = "plot",

      # Legend format
      # Set the legend to be at the top left of the graphic, below title
      legend.position = legend_position,
      legend.text.align = 0,
      legend.background = ggplot2::element_blank(),
      legend.margin = ggplot2::margin(t = 5, r = 5, b = 5, l = 5),
      legend.spacing = ggplot2::unit(2, "cm"),
      legend.key = ggplot2::element_blank(),
      legend.title = ggplot2::element_text(
        family = body_font,
        size = 11 * text_scale,
        face = "bold",
        color = body_color
      ),
      legend.text = ggplot2::element_text(
        family = body_font,
        size = 11 * text_scale,
        color = body_color
      ),

      # Axis format
      axis.text = ggplot2::element_text(
        family = body_font,
        size = 10 * text_scale,
        color = body_color
      ),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      axis.title = ggplot2::element_text(
        family = body_font,
        size = 10 * text_scale,
        color = body_color
      ),
      axis.title.y = ggplot2::element_text(
        angle = 90,
        margin = ggplot2::margin(t = 0, r = 15, b = 0, l = 0)
      ),
      axis.title.x = ggplot2::element_text(
        margin = ggplot2::margin(t = 0, r = 0, b = 0, l = 0)
      ),

      # Grid lines
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = gridline_y,
      panel.grid.major.x = gridline_x,

      # Blank background
      panel.background = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),
      panel.spacing = ggplot2::unit(facet_space, "lines"),

      # Plot fill and margins
      plot.background = ggplot2::element_rect(
        fill = "white",
        color = NA
      ),

      # Facet strip background and text
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(
        family = body_font,
        face = "bold",
        size = 11 * text_scale,
        hjust = 0.5,
        margin = ggplot2::margin(t = 4, r = 4, b = 4, l = 4)
      ),
      ...
    )
}
