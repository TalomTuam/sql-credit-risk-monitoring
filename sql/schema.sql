CREATE TABLE companies (
  company_id INTEGER PRIMARY KEY,
  ticker TEXT NOT NULL UNIQUE,
  company_name TEXT NOT NULL,
  sector TEXT
);

CREATE TABLE debt (
  company_id INTEGER NOT NULL,
  as_of_date TEXT NOT NULL,
  face_value_debt REAL NOT NULL,
  maturity_years REAL NOT NULL,
  PRIMARY KEY (company_id, as_of_date),
  FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE equity_prices (
  company_id INTEGER NOT NULL,
  price_date TEXT NOT NULL,
  equity_price REAL NOT NULL,
  shares_outstanding REAL NOT NULL,
  PRIMARY KEY (company_id, price_date),
  FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE risk_free_rates (
  rate_date TEXT PRIMARY KEY,
  r_annual REAL NOT NULL
);

CREATE TABLE watchlist (
  company_id INTEGER NOT NULL,
  company_name TEXT NOT NULL,
  price_date TEXT NOT NULL,
  debt_to_market_cap REAL,
  vol_2 REAL,
  risk_flag TEXT NOT NULL,
  rule_trigger TEXT NOT NULL,
  PRIMARY KEY (company_id, price_date)
);