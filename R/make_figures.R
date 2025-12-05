make_figure_1 <- function(height = NULL) {
  if (interactive()) {
    suppressWarnings(camcorder::gg_record(width = 7, height = height))
  }

  # Translate the textual data displayed in the figure
  snsf_erc_data_by_instrument |>
    mutate(
      instrument = fct_relabel(instrument, \(x) translate(x, fig_labels)),
      agency = fct_relabel(agency, \(x) translate(x, fig_labels))
    ) |>
    tidyr::pivot_longer(cols = c(n_granted, n_requested), names_to = "type") |>
    mutate(type = fct(type, levels = c("n_requested", "n_granted"))) |>
    ggplot() +
    aes(x = value, y = instrument, fill = fct_rev(agency), alpha = type) +
    geom_col(
      data = \(x) filter(x, type == "n_requested"),
      aes(color = fct_rev(agency)),
      position = position_dodge2(),
      linewidth = 0.25
    ) +
    geom_col(
      data = \(x) filter(x, type == "n_granted"),
      position = position_dodge2(),
      linewidth = 0.25
    ) +
    geom_text(
      data = \(x) filter(x, type == "n_requested"),
      aes(label = value, x = value + 15),
      position = position_dodge(width = 1),
      size = 2.75,
      alpha = 0.5,
      hjust = 0,
      show.legend = FALSE
    ) +
    geom_text(
      data = \(x) filter(x, type == "n_granted"),
      aes(label = value, x = value + 15),
      position = position_dodge(width = 1),
      size = 2.75,
      hjust = 0,
      show.legend = FALSE
    ) +
    scale_x_continuous(
      n.breaks = 7,
      expand = ggplot2::expansion(mult = c(0.0, 0.05)),
      limits = c(0, 3000),
    ) +
    scale_alpha_manual(
      labels = \(x) translate(str_to_sentence(str_remove(x, "n_")), fig_labels),
      values = c(0.3, 1)
    ) +
    scale_fill_datastory() +
    scale_color_datastory(guide = "none") +
    facet_as_hbar(vars(instrument)) +
    get_datastory_theme(
      facet_as_hbar = TRUE,
      legend_position = "right",
      legend_key_size = c(2.5, 7),
      title_axis = "x"
    ) +
    labs(x = translate(fig_labels$`Number of requests and grants`$en, fig_labels)) +
    guides(fill = guide_legend(reverse = TRUE, order = 1))
}

make_figure_2 <- function(height = NULL) {
  if (interactive()) {
    suppressWarnings(camcorder::gg_record(width = 7, height = height))
  }

  # Get the institutions in either the top 5 of ERC or SNSF data in terms of
  # amounts granted.
  top_5 <- unique(
    c(
      snsf_amount_granted_institution$research_institution[1:5],
      erc_amount_granted_institution$snsf_institution[1:5]
    )
  )

  # Combine the SNSF and ERC datasets (and rename the institution variable in
  # the ERC data first).
  plot_dat <- bind_rows(
    snsf_amount_granted_institution,
    rename(
      erc_amount_granted_institution,
      research_institution = snsf_institution
    )
  ) |>
    # Keep only the institution in any top 5
    filter(research_institution %in% top_5) |>
    mutate(
      amount_granted = if_else(
        str_starts(agency, "ERC"), amount_granted * 0.75, amount_granted
      ),
      agency = fct_relabel(agency, \(x) translate(x, fig_labels)),
      research_institution = if_else(
        research_institution == "University of Berne",
        "University of Bern",
        research_institution
      ),
      research_institution = fct_relabel(
        research_institution,
        \(x) translate(x, fig_labels)
      ) |>
        fct_reorder(rank, max, .na_rm = TRUE)
    )

  # Prepare a dataset with the positions of research institution labels to
  # connect those to the end of the bump plot. This is nicer and allow better
  # alignment that when using the legend.
  names_loc <- plot_dat |>
    # Make data are ordered as in the right side of the bump plot and keep only
    # these points.
    filter(agency == fig_labels$`SNSF _par_2021-2024_par_`[params$lang]) |>
    arrange(desc(amount_granted)) |>
    mutate(
      # The distance on the y-axis between labels
      steps = (max(amount_granted) - min(amount_granted)) / 4,
      # The y-axis start of the line linking right side of the bump plot and
      # research institution labels.
      y_start = amount_granted,
      # The y-axis end of the line linking right side of the bump plot and
      # research institution labels.
      y_end = seq(
        max(amount_granted) + unique(steps),
        min(amount_granted) - unique(steps),
        length.out = n()
      ),
      # The x-axis start of the line linking right side of the bump plot and
      # research institution labels.
      x_start = 2,
      # The x-axis end of the line linking right side of the bump plot and
      # research institution labels.
      x_end = 2.15
    )

  plot_dat |>
    ggplot() +
    aes(x = fct_rev(agency), y = amount_granted, group = research_institution) +
    geom_bump(
      aes(color = research_institution),
      show.legend = FALSE
    ) +
    # Add dotted lines linking the right side of the bump plot with the
    # institutions labels (see next geom).
    geom_segment(
      data = names_loc,
      aes(
        x = x_start + 0.04,
        y = y_start,
        xend = x_end - 0.01,
        yend = y_end,
        color = research_institution
      ),
      linetype = "dotted",
      show.legend = FALSE
    ) +
    # Labels with the different institutions in the same order as the right-side
    # of the bump plot.
    geom_text(
      data = names_loc,
      aes(x = x_end, y = y_end, label = research_institution),
      hjust = 0,
      size = 2.5
    ) +
    geom_text(
      data = \(x) filter(x, agency == fig_labels$`ERC _par_2017-2020_par_`[params$lang]),
      aes(
        label = round(amount_granted),
        y = if_else(
          research_institution == fig_labels$`University of Bern`[params$lang],
          amount_granted - 3.05,
          amount_granted + 3.05
        )
      ),
      hjust = 0,
      size = 2.25,
      show.legend = FALSE
    ) +
    geom_text(
      data = \(x) filter(x, agency == fig_labels$`SNSF _par_2021-2024_par_`[params$lang]),
      aes(
        label = round(amount_granted),
        x = as.numeric(agency) + 1.035
      ),
      hjust = 1,
      size = 2.25,
      show.legend = FALSE
    ) +
    scale_color_datastory() +
    scale_x_discrete(expand = ggplot2::expansion(mult = c(0.15, 0.5))) +
    scale_y_continuous(
      limits = c(0, 140),
      n.breaks = 9,
      labels = \(x) paste(
        ifelse(params$lang == "en", "CHF ", ""),
        x, translate(fig_labels$Million$en, fig_labels)
      )
    ) +
    labs(y = translate(fig_labels$`Total amount approuved`$en, fig_labels)) +
    get_datastory_theme(legend_position = "right", title_axis = "y")
}

make_figure_3 <- function(height = NULL) {
  if (interactive()) {
    suppressWarnings(camcorder::gg_record(width = 7, height = height))
  }

  snsf_erc_data_by_domain |>
    tidyr::pivot_longer(
      cols = c(grants_share, requests_share),
      names_to = "type"
    ) |>
    mutate(
      type = fct(type, levels = c("grants_share", "requests_share")),
      agency = fct_relabel(agency, \(x) translate(x, fig_labels)),
      research_domain = fct_relabel(
        research_domain,
        \(x) translate(x, fig_labels)
      )
    ) |>
    ggplot() +
    aes(x = value, y = type, fill = fct_rev(research_domain)) +
    geom_col() +
    geom_text(
      aes(
        label = paste0(
          round(value * 100),
          if_else(params$lang == "fr", " %", "%")
        )
      ),
      position = position_stack(vjust = 0.5),
      color = "white",
      size = 3.5
    ) +
    facet_wrap(vars(agency), ncol = 1) +
    scale_fill_datastory(reverse = TRUE) +
    scale_x_continuous(expand = expansion(mult = c(0.0, 0.05))) +
    scale_y_discrete(
      labels = \(x) {
        translate(
          str_to_sentence(str_remove(x, "_share")),
          fig_labels
        )
      }
    ) +
    labs(
      x = translate(
        fig_labels$`Share of requests and grants by domain`$en,
        fig_labels
      )
    ) +
    get_datastory_theme(title_axis = "x", text_axis = "y") +
    guides(fill = guide_legend(reverse = TRUE))
}

make_figure_4 <- function(height = NULL) {
  if (interactive()) {
    suppressWarnings(camcorder::gg_record(width = 7, height = height))
  }

  snsf_erc_postdoc_sr |>
    mutate(
      instrument = fct_relabel(instrument, \(x) translate(x, fig_labels))
    ) |>
    tidyr::pivot_longer(cols = c(n_granted, n_requested), names_to = "type") |>
    mutate(type = fct(type, levels = c("n_requested", "n_granted"))) |>
    ggplot() +
    aes(x = call_year, y = value, fill = fct_rev(instrument), alpha = type) +
    geom_col(
      data = \(x) filter(x, type == "n_requested"),
    ) +
    geom_col(
      data = \(x) filter(x, type == "n_granted"),
    ) +
    geom_text(
      data = \(x) filter(x, type == "n_requested"),
      aes(label = value, y = value),
      position = position_stack(0.5),
      size = 2.25,
      alpha = 0.5,
      show.legend = FALSE
    ) +
    geom_text(
      data = \(x) filter(x, type == "n_granted"),
      aes(label = value, y = value),
      position = position_stack(0.5),
      size = 2.25,
      show.legend = FALSE
    ) +
    geom_text(
      data = \(x) filter(x, type == "n_requested"),
      aes(
        label = paste0(
          round(sr * 100),
          if_else(params$lang == "fr", " %\n", "%\n"),
          translate("success", fig_labels)
        ),
        y = value + 20
      ),
      alpha = 0.75,
      size = 2.25,
      vjust = 0,
      show.legend = FALSE
    ) +
    scale_y_continuous(
      n.breaks = 8,
      expand = expansion(mult = c(0.025, 0.15))
    ) +
    scale_x_continuous(expand = expansion(mult = c(0.0, 0.05))) +
    scale_alpha_manual(
      labels = \(x) translate(str_to_sentence(str_remove(x, "n_")), fig_labels),
      values = c(0.35, 1)
    ) +
    scale_fill_datastory(reverse = TRUE, guide = "none") +
    facet_wrap(vars(instrument), ncol = 2, scales = "free_x") +
    labs(
      y = translate(fig_labels$`Number of requests and grants`$en, fig_labels)
    ) +
    get_datastory_theme(
      legend_position = "top",
      legend_key_size = c(7, 2.5),
      title_axis = "y"
    )
}
