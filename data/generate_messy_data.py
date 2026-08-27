import numpy as np
import pandas as pd

rng = np.random.default_rng(seed=7)  # a fresh seed - this messiness is a separate random process from the original generator

df = pd.read_csv("data/support_tickets_clean.csv", parse_dates=["created_date", "resolved_date"])

# ---- Missing satisfaction scores (real CSAT surveys have low response rates - most customers never fill them out) ----
missing_satisfaction_mask = rng.random(len(df)) < 0.35
df.loc[missing_satisfaction_mask, "satisfaction_score"] = np.nan

# ---- Missing agent field (rare data-entry gaps, e.g. ticket auto-assigned then unassigned) ----
missing_agent_mask = rng.random(len(df)) < 0.01
df.loc[missing_agent_mask, "agent"] = np.nan

# ---- Inconsistent category text (real exports get typed by different people/systems, never uniform) ----
CATEGORY_VARIANTS = {
    "Technical Issue": ["technical issue", "Technical issue ", "TECH ISSUE"],
    "Billing": ["billing", " Billing", "Bill"],
    "Account Access": ["account access", "Account  Access"],
    "Product Question": ["product question", "Product Qustion"],
    "Complaint": ["complaint", "COMPLAINT"],
    "Refund Request": ["refund request", "Refund Reqeust"],
}

def messy_category(cat):
    if cat in CATEGORY_VARIANTS and rng.random() < 0.15:
        return rng.choice(CATEGORY_VARIANTS[cat])
    return cat

df["category"] = df["category"].apply(messy_category)
# ---- Duplicate rows (ticket accidentally exported twice - common in real system exports) ----
n_duplicates = int(len(df) * 0.02)
duplicate_rows = df.sample(n=n_duplicates, random_state=rng)
df = pd.concat([df, duplicate_rows], ignore_index=True)

# ---- A few impossible values (data entry errors - e.g. a negative resolution time makes no physical sense) ----
n_errors = 10
error_idx = rng.choice(df.index, size=n_errors, replace=False)
df.loc[error_idx, "resolution_time_hours"] = -df.loc[error_idx, "resolution_time_hours"]
df.to_csv("data/support_tickets_raw.csv", index=False)

print(f"Missing satisfaction_score: {df['satisfaction_score'].isnull().sum()} ({df['satisfaction_score'].isnull().mean():.1%})")
print(f"Missing agent: {df['agent'].isnull().sum()} ({df['agent'].isnull().mean():.1%})")
print(f"\nUnique category values now: {df['category'].nunique()} (should be more than the original 6)")
print(df["category"].value_counts())
print(f"\nTotal rows now: {len(df)} (started at 5000, so this many are duplicates: {df['ticket_id'].duplicated().sum()})")
print(f"Rows with impossible negative resolution_time_hours: {(df['resolution_time_hours'] < 0).sum()}")
print(f"\nSaved messy raw dataset to data/support_tickets_raw.csv ({len(df)} rows)")