# Ontario Electricity: Demand, Weather & Time-of-Use Cost Analysis (2024)

An end-to-end data analysis of Ontario's 2024 hourly electricity demand, joined with
Toronto weather and Time-of-Use (TOU) pricing to understand what drives demand and
where electricity costs concentrate.

**Live dashboard:** [View on Tableau Public]((https://public.tableau.com/views/OntarioElectricityDemandWeatherTime-of-UseCostAnalysis2024/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link))

**Tools:** Python (Pandas) · MySQL · Tableau

---

## Problem

Ontario households are billed on Time-of-Use pricing, where the rate per kilowatt-hour
changes based on the time of day, day of week, and season. This project asks:

- What drives electricity demand across the year?
- When does demand — and therefore cost — concentrate?
- What can be done to reduce cost without reducing usage?

## Data Sources

| Source | Data | Records |
|---|---|---|
| IESO (Independent Electricity System Operator) | Hourly Ontario demand, 2024 | 8,784 hours |
| Environment and Climate Change Canada | Hourly temperature, Toronto City station | 8,784 hours |
| Ontario Energy Board | Time-of-Use rate schedule | off / mid / on-peak |

## Method

**1. Data collection & cleaning (Python / Pandas)**
- Parsed the raw IESO demand file (handled disclaimer rows, converted the 1–24 hour
  format into proper hourly timestamps).
- Combined 12 monthly Environment Canada weather files into a single table.
- Merged demand and weather on the hourly timestamp and interpolated 7 missing
  temperature readings. Result: one clean dataset of 8,784 hourly rows.

**2. Time-of-Use billing engine (MySQL)**
- Classified every hour as off-peak, mid-peak, or on-peak based on season, weekday,
  and hour — mirroring how a utility billing system applies rates.
- Applied the per-period rate (off 9.8¢, mid 15.7¢, on 20.3¢) to each hour's demand
  and aggregated into monthly costs and period breakdowns.

**3. Visualization (Tableau)**
- Built a five-view dashboard: monthly cost by TOU period, demand-vs-temperature,
  peak-demand heatmap, KPI cards, and cost share by period.

## Key Findings

- **Demand follows a U-curve with temperature** — lowest around 15°C and rising at both
  cold (heating) and hot (air conditioning) extremes, with heat driving the steeper climb.
- **On-peak hours are only ~18% of the year (1,572 of 8,784 hours) but account for
  30.7% of total cost** — cost concentrates heavily in summer afternoons and winter evenings.
- Off-peak power costs 9.8¢/kWh versus 20.3¢ on-peak — roughly 52% cheaper overnight.

## Recommendation

Because on-peak power costs about 52% more per kilowatt-hour than off-peak, the
highest-leverage action is to shift *flexible* load out of on-peak afternoons into
off-peak overnight hours — scheduling EV charging, laundry, dishwashers, and pool pumps
overnight, and pre-cooling homes before the afternoon peak rather than during it.
Flexible loads are typically 20–30% of household usage; shifting even half of on-peak
consumption off-peak meaningfully reduces the annual bill without using less power —
simply by using it at a smarter time. For a utility, the data supports targeted
demand-response incentives aimed at the summer-afternoon peak.

## Files

| File | Description |
|---|---|
| `clean_demand.py` | Cleans the raw IESO demand file into a tidy hourly dataset |
| `build_weather.py` | Merges 12 months of weather with demand, fills gaps |
| `tou_billing.sql` | TOU classification, rate application, and monthly aggregation |
| `demand_weather_2024.csv` | Final cleaned dataset (8,784 hourly rows) |

## Author

Abhiram Vasara — Kitchener, ON
