# Community Decision Intelligence (CDIS) — Shiny App

Purpose:
A decision-focused Shiny app that transforms routine monitoring exports into locally-interpretable insights and recommended experiments. Built for district teams and NGOs operating in Masindi and Kiryandongo (Uganda).

Main features:
- Upload Kobo/CSV / DHIS2 facility exports
- Data cleaning & canonicalization for facility names and dates
- Indicator generation (attendance trends, dropouts, service uptake)
- Explainable rule engine producing practical recommendations
- Simple anomaly detection & intervention A/B trial planner
- Exportable "decision brief" (PDF) for local meetings

 packages: `source("packages.R")`
 Launch: `shiny::runApp("app.R")`

