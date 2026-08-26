import numpy as np
import pandas as pd

# ---- Reproducibility ----
rng = np.random.default_rng(seed=42)

# ---- Volume & time window ----
N_TICKETS = 5000
START_DATE = "2025-01-01"
END_DATE = "2025-12-31"

# ---- Support channels (weighted) ----
CHANNELS = ["Email", "Phone", "Chat", "Social Media"]
CHANNEL_WEIGHTS = [0.45, 0.30, 0.20, 0.05]

# ---- Ticket category ----
CATEGORIES = ["Billing", "Technical Issue", "Account Access", "Product Question", "Complaint", "Refund Request"]
CATEGORY_WEIGHTS = [0.20, 0.30, 0.15, 0.15, 0.12, 0.08]

# ---- Priority ----
PRIORITIES = ["Low", "Medium", "High", "Urgent"]
PRIORITY_WEIGHTS = [0.35, 0.40, 0.20, 0.05]

# ---- Ticket status ----
STATUSES = ["Resolved", "Closed", "Reopened"]
STATUS_WEIGHTS = [0.75, 0.20, 0.05]

# ---- Agents (persistent skill factor) ----
AGENTS = [f"Agent_{i:02d}" for i in range(1, 21)]
agent_skill = {agent: rng.normal(loc=1.0, scale=0.15) for agent in AGENTS}
agent_skill = {agent: float(np.clip(skill, 0.6, 1.6)) for agent, skill in agent_skill.items()}

# ---- Priority speed multiplier ----
PRIORITY_SPEED = {"Urgent": 0.4, "High": 0.6, "Medium": 1.0, "Low": 1.3}

# ---- Generate the base columns ----
ticket_id = [f"TCK-{i:05d}" for i in range(1, N_TICKETS + 1)]

date_pool = pd.date_range(start=START_DATE, end=END_DATE, freq="D")
created_date = rng.choice(date_pool, size=N_TICKETS)

channel = rng.choice(CHANNELS, size=N_TICKETS, p=CHANNEL_WEIGHTS)
category = rng.choice(CATEGORIES, size=N_TICKETS, p=CATEGORY_WEIGHTS)
priority = rng.choice(PRIORITIES, size=N_TICKETS, p=PRIORITY_WEIGHTS)
agent = rng.choice(AGENTS, size=N_TICKETS)

# ---- Advanced Metrics Generation ----
base_resolution_hours = rng.lognormal(mean=np.log(4), sigma=0.6, size=N_TICKETS)
priority_multiplier = np.array([PRIORITY_SPEED[p] for p in priority])
agent_multiplier = np.array([agent_skill[a] for a in agent])
resolution_time_hours = np.round(base_resolution_hours * priority_multiplier * agent_multiplier, 2)

# ---- Piece 4: Resolved Date and Customer Satisfaction ----
resolved_date = created_date + pd.to_timedelta(resolution_time_hours, unit="h")

satisfaction_raw = 4.5 - 0.15 * resolution_time_hours + rng.normal(loc=0, scale=0.7, size=N_TICKETS)
satisfaction_score = np.clip(np.round(satisfaction_raw), 1, 5).astype(int)

# ---- Piece 5: Status ----
status = rng.choice(STATUSES, size=N_TICKETS, p=STATUS_WEIGHTS)

# Combine into a single table
df = pd.DataFrame({
    "ticket_id": ticket_id,
    "created_date": created_date,
    "resolved_date": resolved_date,
    "channel": channel,
    "category": category,
    "priority": priority,
    "agent": agent,
    "resolution_time_hours": resolution_time_hours,
    "satisfaction_score": satisfaction_score,
    "status": status,
})

# ---- Piece 5: Chronological Sort and Data Export ----
df = df.sort_values("created_date").reset_index(drop=True)
df.to_csv("data/support_tickets_clean.csv", index=False)

# Diagnostics and Sanity Checks
print("--- DATAFRAME CHRONOLOGICAL PREVIEW ---")
print(df.head(10))
print(f"\nShape: {df.shape}")
print(f"\nNull values per column:\n{df.isnull().sum()}")
print(f"\nStatus distribution:\n{df['status'].value_counts(normalize=True)}")
print("\nSaved to data/support_tickets_clean.csv")
