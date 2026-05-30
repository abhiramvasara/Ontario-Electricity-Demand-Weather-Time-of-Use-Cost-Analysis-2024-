import pandas as pd
import glob

files = sorted(glob.glob("en_climate_hourly_ON_6158355_*-2024_P1H.csv"))
weather = pd.concat([pd.read_csv(f) for f in files], ignore_index=True)

weather["datetime"] = pd.to_datetime(weather["Date/Time (LST)"])
weather = weather[["datetime", "Temp (\u00b0C)"]].rename(columns={"Temp (\u00b0C)": "temp_c"})

demand = pd.read_csv("demand_2024_clean.csv")
demand["datetime"] = pd.to_datetime(demand["datetime"])

merged = demand.merge(weather, on="datetime", how="inner")
merged = merged.sort_values("datetime").reset_index(drop=True)
merged["temp_c"] = merged["temp_c"].interpolate(method="linear")

merged.to_csv("demand_weather_2024.csv", index=False)
print(merged.shape, merged["temp_c"].isna().sum())
