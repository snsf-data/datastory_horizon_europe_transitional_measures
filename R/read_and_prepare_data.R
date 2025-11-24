
#==============================================================================#
#                            ---- Read the data ----
#==============================================================================#

# Read SNSF data about funded grants for the HE Transitional Measures
# instruments.
snsf_amount_institutions <- read_csv(
  here("data", "snsf_amount_institutions.csv")
) |>
  mutate(
    instrument = fct(
      instrument,
      levels = c(
        "SNSF Swiss Postdoctoral Fellowships",
        "SNSF Starting Grants",
        "SNSF Consolidator Grants",
        "SNSF Advanced Grants"
      )
    )
  )

# Load the aggregated data with the number of proposals (requests), funded
# proposals (grants), the amount granted, and the success rate, by instrument,
# call year, and research domain. The instrument correspond to the four
# instruments set up by the SNSF as transitional measures during its exclusion
# of Horizon Europe.
snsf_sr_summary <- read_csv(here("data", "snsf_sr_summary.csv"))

# Load data from the European Research Council. The data were downloaded from
# the ERC dashboard on 2025-09-29. The filter used where: host institution in
# Switzerland, any grants from "Starting Grants", "Advanced Grants", or
# "Consolidator Grants", with a call year period corresponding to 2017-2020.
erc_grants_dat <- read_csv(here("data", "erc_data.csv"))

# Load data regarding the number of evaluated proposals by the ERC. The data
# were manually collected from the ERC dashbord. The data were manually
# collected on 2025-09-29 for each level of call year (2017-2020), instrument
# ("Starting Grants", "Advanced Grants", and "Consolidator Grants"), and each
# research domain (SH, LS, and PE).
erc_proposals_dat <- read_csv(
  here("data", "erc_proposals_by_domain_and_year.csv")
)

# Load data on the number of evaluated proposals, granted proposals, and amount
# granted for call year 2017-2020 of the Marie Sklodowska Curie Actions. Data
# were collected internally.
msca_dat <- read_csv(here("data", "msca_swiss.csv"))

#==============================================================================#
#                            ---- In-text data ----
#==============================================================================#

# Number of grants and amounts awarded by the SNSF during the call year period
# 2021-2024 as transitional measures.
n_grants_snsf <- sum(snsf_sr_summary$n_granted)
n_amount_approved_snsf <- sum(snsf_sr_summary$amount_granted)

n_female <-  sum(snsf_sr_summary$n_female)
n_male <-  sum(snsf_sr_summary$n_male)
n_non_binary <-  sum(snsf_sr_summary$n_non_binary)
share_female <- n_female / sum(c(n_female, n_male, n_non_binary))

# Number of grants awarded by the SNSF and the ERC to the ETH Zurich, which is
# the institution that received the most grants/funding (this was determined
# based on a previous analysis of the data).
grants_ethz_snsf <- snsf_amount_institutions |>
  filter(
    research_institution == "ETH Zurich",
    !str_detect(instrument, "Post")
  ) |>
  summarise(grants = sum(n_granted))

grants_ethz_erc <- erc_grants_dat |>
  filter(snsf_institution == "ETH Zurich") |>
  summarise(grants = n())

# Number of grant requested and awarded by the SNSF and the ERC for each
# research domain. Postdoctoral level/MSCA is excluded.
n_grants_by_domain_snsf <- snsf_sr_summary |>
  filter(!str_detect(instrument, "Post")) |>
  summarise(
    n = sum(n_granted),
    .by = research_domain
  )
n_requests_by_domain_snsf <- snsf_sr_summary |>
  filter(!str_detect(instrument, "Post")) |>
  summarise(
    n = sum(n_requested),
    .by = research_domain
  )
n_grants_by_domain_erc <- count(erc_grants_dat, research_domain)
n_requests_by_domain_erc <- erc_proposals_dat |>
  summarise(
    n = sum(n_requested, na.rm = TRUE),
    .by = research_domain
  )

n_requests_spf <- snsf_sr_summary |>
  filter(str_detect(instrument, "Post")) |>
  summarise(
    n = sum(n_requested),
    .by = instrument
  )
n_grants_spf <- snsf_sr_summary |>
  filter(str_detect(instrument, "Post")) |>
  summarise(
    n = sum(n_granted),
    .by = instrument
  )

n_requests_msca <- sum(msca_dat$n_requested)
n_grants_msca <- sum(msca_dat$n_granted)

spf_success_rate <- snsf_sr_summary |>
  filter(str_detect(instrument, "Post")) |>
  summarise(sr = sum(n_granted) / sum(n_requested))
msca_success_rate <- sum(msca_dat$n_granted) / sum(msca_dat$n_requested)

#==============================================================================#
#                         ---- Visualization data ----
#==============================================================================#

# The order of the SNSF/ERC instruments levels
instrument_snsf_erc_levels <- c(
  "Postdoctoral Fellowships/MSCA",
  "Starting Grants",
  "Consolidator Grants",
  "Advanced Grants"
)

## Figure 1 --------------------------------------------------------------------

# Summary of SNSF data with grants requested and funded by instrument
snsf_requests_grants_by_instrument <- snsf_sr_summary |>
  summarise(
    n_requested = sum(n_requested),
    n_granted = sum(n_granted),
    agency = "SNSF (2021-2024)",
    .by = instrument
  )

# Summary of ERC data with grants requested and funded by instrument
erc_requests_grants_by_instrument <- erc_proposals_dat |>
  # Summarise ERC proposals data by instruments
  summarise(
    n_requested = sum(n_requested),
    .by = instrument
  ) |>
  # Join ERC data on grants by instrument
  left_join(
    count(erc_grants_dat, instrument, name = "n_granted"),
    by = join_by(instrument)
  ) |>
  # Bind MSCA data on grants and requests by instrument
  bind_rows(
    summarise(
      msca_dat,
      n_requested = sum(n_requested),
      n_granted = sum(n_granted),
      .by = instrument
    )
  ) |>
  # Add a variable indicating funding agency
  mutate(agency = "ERC (2017-2020)")

# Bind together datasets from the SNSF and ERC for figure 1
snsf_erc_data_by_instrument <- bind_rows(
  snsf_requests_grants_by_instrument,
  erc_requests_grants_by_instrument
) |>
  mutate(
    # Set up the order of levels of the agency variable
    agency = fct(agency, levels = c("SNSF (2021-2024)", "ERC (2017-2020)")),
    # Harmonize the names of the funding instruments between agencies and set
    # it as a factor with fixed levels.
    instrument = if_else(
      str_detect(instrument, "Swiss|Marie"),
      "Postdoctoral Fellowships/MSCA",
      str_remove(instrument, "SNSF\\s")
    ) |>
      fct(levels = instrument_snsf_erc_levels)
  ) |>
  arrange(agency, instrument)

## Figure 2 --------------------------------------------------------------------

# Summary of SNSF data with grants requested and funded by research institution
snsf_amount_granted_institution <- snsf_amount_institutions |>
  # Remove SNSF Swiss Postdoctoral Fellowship as we do not have data related to
  # host institution for MSCA data.
  filter(!str_detect(instrument, "Post")) |>
  # Summarize the amount granted by research institution (million CHF)
  summarise(
    amount_granted = sum(amount_granted) / 1000000,
    .by = research_institution
  ) |>
  # Sort based on the amount granted, and add an "agency" variable.
  arrange(desc(amount_granted)) |>
  mutate(
    rank = row_number(),
    agency = fct(
      "SNSF (2021-2024)",
      levels = c("SNSF (2021-2024)", "ERC (2017-2020)")
    )
  )
# Table with exchange rate between CHF and EUR between 2017 and 2020. This is
# needed to transform amounts funded in EUR from the ERC into CHF. Rates were
# taken from the Swiss National Bank:
# https://data.snb.ch/fr/topics/ziredev/cube/devkua?fromDate=2017&dimSel=D1(EUR1)&toDate=2020
eur_to_chf <- tribble(
  ~call_year, ~eur, ~chf,
  2017, 1, 1.1116,
  2018, 1, 1.1549,
  2019, 1, 1.1125,
  2020, 1, 1.0705,
)

# Summary of ERC data with grants requested and funded by research institution
erc_amount_granted_institution <- erc_grants_dat |>
  # Add exchange rates and transform amount granted in EUR to CHF
  left_join(eur_to_chf, by = join_by(call_year)) |>
  mutate(amount_granted = amount_granted * chf) |>
  select(!c(eur, chf)) |>
  # Summarize the amount granted by research institution (million CHF)
  summarise(
    amount_granted = sum(amount_granted) / 1000000,
    .by = snsf_institution
  ) |>
  # Sort based on the amount granted, set a rank based on the rearranged
  # position, and add an "agency" variable.
  arrange(desc(amount_granted)) |>
  mutate(
    agency = fct(
      "ERC (2017-2020)",
      levels = c("SNSF (2021-2024)", "ERC (2017-2020)")
    )
  )

## Figure 3 --------------------------------------------------------------------

# Summary of SNSF data with grants requested and funded by research domain
snsf_requests_grants_by_domain <- snsf_sr_summary |>
  # Remove SNSF Swiss Postdoctoral Fellowship as we do not have data related to
  # research domain for MSCA data.
  filter(!str_detect(instrument, "Post")) |>
  summarise(
    n_requested = sum(n_requested),
    n_granted = sum(n_granted),
    .by = research_domain
  ) |>
  # Reformat the research domain names so they are aligned between SNSF and ERC
  mutate(
    requests_share = n_requested / sum(n_requested),
    grants_share = n_granted / sum(n_granted),
    research_domain = case_match(
      research_domain,
      "SSH" ~ "SSH/SH",
      "MINT" ~ "MINT/PE",
      .default = research_domain
    ),
    agency = "SNSF (2021-2024)"
  )

# Summary of ERC data with grants requested and funded by instrument
erc_requests_grants_by_domain <- erc_proposals_dat |>
  # Summarise ERC proposals data by instruments
  summarise(
    n_requested = sum(n_requested),
    .by = research_domain
  ) |>
  # Join ERC data on grants by instrument
  left_join(
    count(erc_grants_dat, research_domain, name = "n_granted"),
    by = join_by(research_domain)
  ) |>
  # Reformat the research domain names so they are aligned between SNSF and ERC
  mutate(
    requests_share = n_requested / sum(n_requested),
    grants_share = n_granted / sum(n_granted),
    research_domain = case_when(
      str_detect(research_domain, "(SH)") ~ "SSH/SH",
      str_detect(research_domain, "(PE)") ~ "MINT/PE",
      str_detect(research_domain, "(LS)") ~ "LS"
    ),
    agency = "ERC (2017-2020)"
  )

snsf_erc_data_by_domain <- bind_rows(
  snsf_requests_grants_by_domain,
  erc_requests_grants_by_domain
) |>
  mutate(
    agency = fct(agency, levels = c("SNSF (2021-2024)", "ERC (2017-2020)")),
    research_domain = fct(
      research_domain,
      levels = c("SSH/SH", "MINT/PE", "LS")
    )
  ) |>
  arrange(agency, research_domain)

## Figure 4 --------------------------------------------------------------------

# Summary of SNSF Swiss Postdoctorl Fellwoships (requests, grants, and success
# rate).
snsf_spf_sr_year <- snsf_sr_summary |>
  filter(str_detect(instrument, "Post")) |>
  summarise(
    n_requested = sum(n_requested),
    n_granted = sum(n_granted),
    sr = n_granted / n_requested,
    amount_granted = sum(amount_granted),
    .by = c(instrument, call_year)
  )

# Summary of Marie Sklodowska Curie Actions (requests, grants, and success rate)
msca_sr_year <- msca_dat |>
  mutate(
    sr = n_granted / n_requested,
    .before = amount_granted,
    .by = c(instrument, call_year)
  ) |>
  relocate(instrument)

# Combine the data on postdoctoral instruments from the SNSF and ERC
snsf_erc_postdoc_sr <- bind_rows(snsf_spf_sr_year, msca_sr_year) |>
  mutate(
    instrument = fct(
      instrument,
      levels = c(
        "Marie Sklodowska Curie Actions",
        "SNSF Swiss Postdoctoral Fellowships"
      )
    )
  )
