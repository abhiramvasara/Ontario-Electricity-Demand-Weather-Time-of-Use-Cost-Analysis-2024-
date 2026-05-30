import pandas as pd

df = pd.read_csv("PUB_Demand_2024.csv", skiprows=3)
df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

df["date"] = pd.to_datetime(df["date"], format="%Y-%m-%d")
df["datetime"] = df["date"] + pd.to_timedelta(df["hour"] - 1, unit="h")

df["year"] = df["datetime"].dt.year
df["month"] = df["datetime"].dt.month
df["day"] = df["datetime"].dt.day
df["hour24"] = df["datetime"].dt.hour
df["weekday"] = df["datetime"].dt.dayofweek
df["is_weekend"] = df["weekday"] >= 5

clean = df[["datetime", "year", "month", "day", "hour24",
            "weekday", "is_weekend", "ontario_demand", "market_demand"]]

clean.to_csv("demand_2024_clean.csv", index=False)
print(clean.shape)
