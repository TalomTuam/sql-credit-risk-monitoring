# SQL Credit Risk Monitoring System

This project implements a simplified credit risk monitoring framework using SQL (SQLite).

## Features
- Relational data model (companies, debt, equity prices)
- Market capitalization calculation
- Debt-to-Market-Cap leverage ratio
- Daily equity returns using window functions (LAG)
- Rolling volatility estimation
- Automated watchlist generation with rule-based risk flags

## Risk Rules
A company is flagged as RISKY if:
- Debt-to-Market-Cap > 0.9
OR
- Rolling volatility > 0.04

## Technologies
- SQLite
- Window Functions
- CTEs
- Analytical SQL

## How to Run
1. Execute schema.sql
2. Execute seed.sql
3. Execute views.sql
4. Execute build_watchlist.sql