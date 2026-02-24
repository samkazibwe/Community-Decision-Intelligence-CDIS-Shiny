# Create seed datasets representative of Masindi and Kiryandongo operations
library(tidyverse)
library(lubridate)
set.seed(42)

# Facilities and communities
facilities <- tibble(
  facility = c("Pakanyi HC","Nyantonzi HC","Bwijanga Clinic","Kiryandongo HC"),
  subcounty = c("Buseruka","Buseruka","Kigorobya","Kiryandongo"),
  district = c("Masindi","Masindi","Masindi","Kiryandongo")
)

# Outreach events: daily records for 18 months
dates <- seq(as.Date("2024-01-01"), as.Date("2025-12-31"), by="day")
outreach <- expand.grid(date=dates, facility=facilities$facility) %>%
  as_tibble() %>%
  mutate(service = sample(c("Immunization","ANC","Outreach","Nutrition"), n(), replace=TRUE, prob=c(.35,.2,.25,.2)),
         attendance = rpois(n(), lambda = case_when(service=="Immunization" ~ 18,
                                                   service=="ANC" ~ 8,
                                                   service=="Outreach" ~ 22,
                                                   TRUE ~ 10)),
         note = sample(c("normal","market_day","rain","village_event","road_block"), n(), replace=TRUE, prob=c(.7,.08,.08,.08,.06))) %>%
  left_join(facilities, by="facility") %>%
  arrange(facility, date)

# Facility registers (monthly aggregations)
facility_registers <- outreach %>%
  mutate(month = floor_date(date,"month")) %>%
  group_by(facility, month) %>%
  summarise(total_attendance = sum(attendance), n_events = n(), .groups="drop")

# Waterpoint maintenance log (used by water teams)
waterlogs <- tibble(
  id = paste0("WP",1001:1200),
  location = sample(c("Nyantonzi Parish","Pakanyi Parish","Bwijanga Parish"), 200, replace=TRUE),
  last_reported_status = sample(c("functional","non-functional"),200, replace=TRUE, prob=c(.78,.22)),
  last_repair_date = sample(seq(as.Date("2023-01-01"), as.Date("2025-02-01"), by="day"), 200, replace=TRUE),
  yield_lpm = round(runif(200, 2, 30),1)
)

# Save CSVs
dir.create("data", showWarnings=FALSE)
write_csv(outreach, "data/outreach_masindi.csv")
write_csv(facility_registers, "data/facility_registers_masindi.csv")
write_csv(waterlogs, "data/waterpoints_masindi.csv")
message("Seed data created in data/*.csv")
