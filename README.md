# Datastory: *How did the SNSF's transitional measures differ from European calls?*

*Between 2021 and 2024, the SNSF implemented measures to compensate for the exclusion of Swiss researchers from the Horizon Europe programme. Our analysis reveals differences between the SNSF and the European Research Council.*

[English](https://data.snf.ch/stories/horizon-europe-transitional-measures-en.html)\
[German](https://data.snf.ch/stories/ubergangsmassnahmen-horizon-europe-de.html)\
[French](https://data.snf.ch/stories/mesures-transitoires-horizon-europe-fr.html)

**Author(s)**: Chloé Liechti, Simon Gorin

**Publication date**: 25.11.2025

# Data description

The data used in this data story are available in the folder `data`. The files (`data/msca_swiss.csv`, `data/erc_data.csv`, `data/erc_proposals_by_domain_and_year.csv`, `data/snsf_sr_summary.csv`, `data/snsf_amount_institutions.csv`, and `data/figure_translations.csv`) contain funding statistics from the Marie Skłodowska-Curie Actions and the European Research Council for the period 2017–2020, as well as SNSF's Horizon Europe transitional measures for the period 2021–2024. Note that the "Quantum Transitional Call" and the "Swiss Quantum Call 2024" are note included in this data story.

## `msca_swiss.csv`

Summary data about the Marie Skłodowska-Curie Actions for the period 2017-2020. The data were collected manually via the [Horizon Dashboard](https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/opportunities/horizon-dashboard). For the data about the number of requests and grants, we used the [R&I Proposals](https://dashboard.tech.ec.europa.eu/qs_digit_dashboard_mt/public/sense/app/28b39a3a-4d62-4180-9dfa-551489b06928/sheet/fa944260-9e39-410a-9bf5-326357748d0b/state/analysis) dashboard. For the amounts granted, we used the [R&I Projects](https://dashboard.tech.ec.europa.eu/qs_digit_dashboard_mt/public/sense/app/28b39a3a-4d62-4180-9dfa-551489b06928/sheet/fa944260-9e39-410a-9bf5-326357748d0b/state/analysis) dashboard. When collecting the data, we used the following filters for the two dashboards:

-   Programme: "H2020"
-   Country: "Switzerland"
-   Call ID: "MSCA-IF-201"7, "MSCA-IF-2018", "MSCA-IF-2019", "MSCA-IF-2020"
-   Type of Action: all, except "Global Fellowships" (GF)

Here is a list of the variables available in ` msca_swiss.csv`.

-   `call_year`: the `Year` variable in the Horizon dashboard
-   `instrument`: the instrument (always "Marie Sklodowska Curie Actions")
-   `n_requested`: the number of proposals
-   `n_granted`: the number of approved proposals
-   `amount_granted`: the amount granted to approved proposals (net EU contribution)

## `erc_data.csv`

Data about projects funded by the European Research Council (ERC) for host institutions located in Switzerland, and for the period 2017-2020. The data where downloaded from the ERC dashboard (follow this [link](https://dashboard.tech.ec.europa.eu/qs_digit_dashboard_mt/public/single/?appid=c140622a-87e0-412e-8b29-9b5ddd857e13&sheet=61a0bd1d-cd6d-4ac8-8b55-80d8661e44c0&theme=horizon&opt=ctxmenu,currsel&select=$::Grant%20Type,Advanced%20Grants,Consolidator%20Grants,Starting%20Grants&select=$::Country,Switzerland) to get the exact filters). After the download, we filtered the data with `call_year` between 2017 and 2020.

-   `programme`: the `Programme` variable in the ERC dashboard
-   `acronym`: the `Acronym` variable in the ERC dashboard
-   `project_title`: the `Project Title` variable in the ERC dashboard
-   `abstract`: the `Abstract` variable in the ERC dashboard
-   `researcher`: the `Researcher(s)` variable in the ERC dashboard
-   `host_institution`: the `Host Institution(s)` variable in the ERC dashboard
-   `country`: the `Country` variable in the ERC dashboard
-   `region`: the `Region` variable in the ERC dashboard
-   `project_number`: the `Project Number` variable in the ERC dashboard
-   `call`: the `Call` variable in the ERC dashboard
-   `instrument`: the `Grant Type` variable in the ERC dashboard
-   `research_domain`: the `Domain` variable in the ERC dashboard
-   `panel`: the `Panel` variable in the ERC dashboard
-   `call_year`: the `Year` variable in the ERC dashboard
-   `start_date`: the `Start Date` variable in the ERC dashboard
-   `end_date`: the `End Date` variable in the ERC dashboard
-   `amount_granted`: the `EU contribution` variable in the ERC dashboard
-   `cordis_link`: the `CORDIS Link` variable in the ERC dashboard
-   `snsf_institution`: the institution name used at the SNSF that we manually matched to the `Host Institution(s)` variable available in the ERC dashboard.

## `erc_proposals_by_domain_and_year.csv`

Data about proposals evaluated by the European Research Council (ERC) for host institutions located in Switzerland, and for the period 2017-2020. The data where accessed using the same link as for the `erc_data.csv` data, but focusing on the "Evaluated Proposals" panel. The data where collected manually from the ERC dashboard.

-   `call_year`: the `Programme` variable in the ERC dashboard
-   `instrument`: the `Grant Type` variable in the ERC dashboard
-   `research_domain`: the `domain` variable in the ERC dashboard
-   `n_requested`: the number of funding requests submitted to the ERC

## `snsf_sr_summary.csv`

Summary data about the transitional measures instruments described in the data story.

-   `instrument`: the transitional measures instrument
-   `call_year`: the call year of the instrument
-   `research_domain`: the highest hierarchical discipline level, consisting of the three research areas (Humanities and social sciences; Mathematics, natural and engineering sciences; Biology and medicine)
-   `n_requested`: the total number of proposals submitted
-   `n_granted`: the total number of approved proposals
-   `success_rate`: the share of approved proposals among the total number of proposals submitted
-   `amount_granted`: the total amount granted for all grants
-   `n_male`: the number of grants with a male responsible applicant
-   `n_female`: the number of grants with a female responsible applicant
-   `n_non_binary`: the number of grants with a non-binary responsible applicant

## `snsf_amount_institutions.csv`

Summary data by research institution about the transitional measures instruments described in the data story.

-   `instrument`: the transitional measures instrument
-   `call_year`: the call year of the instrument
-   `research_institution`: the Swiss research institution or university where the grant is largely carried out according to the application
-   `n_granted`: the total number of approved proposals
-   `amount_granted`: the total amount granted for all grants

## `figure_translations.csv`

This data set contains all translations of the text elements appearing in the figures presented in the data story. The translations are required to render the data story in the different languages. Each row contains one text element of the respective figure.

-   `Figure`: the number of the figure by appearance order in the data story
-   `en`: a list of all the text elements (labels, data annotations, axis titles,...) appearing in the data story figures in English
-   `de`: German translation of the data story figure texts in `en`
-   `fr`: French translation of the data story figure texts in `en`
-   `it`: Italian translation of the data story figure texts in `en`[^1]

[^1]: There is no Italian version of the data story on the SNSF Data Portal, but the data story was translated to Italian and published as news in the [Italian version of the SNSF website](https://www.fns-it.ch/it/mmItiOmxilN4k1FU/pagina/attualita).
