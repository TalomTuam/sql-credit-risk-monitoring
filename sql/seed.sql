INSERT INTO companies VALUES
(1, 'ALPHA', 'Alpha AG', 'Industrials'),
(2, 'BETA', 'Beta SE', 'Consumer');

INSERT INTO debt VALUES
(1, '2025-12-31', 500000000, 5.0),
(2, '2025-12-31', 200000000, 3.0);

INSERT INTO equity_prices VALUES
(1, '2025-12-28', 50, 10000000),
(1, '2025-12-29', 52, 10000000),
(1, '2025-12-30', 51, 10000000),
(2, '2025-12-28', 30, 8000000),
(2, '2025-12-29', 31, 8000000),
(2, '2025-12-30', 29, 8000000);

INSERT INTO risk_free_rates VALUES
('2025-12-31', 0.03);

SELECT * FROM companies;
SELECT * FROM debt;
SELECT * FROM equity_prices;
SELECT * FROM risk_free_rates;

SELECT COUNT(*) FROM companies;
SELECT COUNT(*) FROM debt;
SELECT COUNT(*) FROM equity_prices;
SELECT COUNT(*) FROM risk_free_rates;

SELECT
  (SELECT COUNT(*) FROM companies)      AS n_companies,
  (SELECT COUNT(*) FROM debt)           AS n_debt_rows,
  (SELECT COUNT(*) FROM equity_prices)  AS n_equity_prices,
  (SELECT COUNT(*) FROM risk_free_rates) AS n_rates;
  
  CREATE VIEW v_market_cap AS
SELECT
    company_id,
    price_date,
    equity_price,
    shares_outstanding,
    equity_price * shares_outstanding AS market_cap
FROM equity_prices;

CREATE VIEW v_equity_returns AS
SELECT
    company_id,
    price_date,
    equity_price,
    (equity_price - LAG(equity_price) OVER (
        PARTITION BY company_id
        ORDER BY price_date
    )) 
    / LAG(equity_price) OVER (
        PARTITION BY company_id
        ORDER BY price_date
    ) AS daily_return
FROM equity_prices;

SELECT * 
FROM v_equity_returns
ORDER BY company_id, price_date;

CREATE VIEW v_leverage AS
SELECT
    c.company_id,
    c.company_name,
    e.price_date,
    d.as_of_date,
    d.face_value_debt,
    e.equity_price * e.shares_outstanding AS market_cap,
    d.face_value_debt / (e.equity_price * e.shares_outstanding) AS debt_to_market_cap
FROM companies c
JOIN equity_prices e
    ON c.company_id = e.company_id
JOIN debt d
    ON c.company_id = d.company_id;
	
SELECT *
FROM v_leverage
ORDER BY company_id, price_date;

CREATE VIEW v_vol_2 AS
SELECT
    company_id,
    price_date,
    SQRT(
        AVG(daily_return * daily_return) OVER (
            PARTITION BY company_id
            ORDER BY price_date
            ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
        )
        -
        (
            AVG(daily_return) OVER (
                PARTITION BY company_id
                ORDER BY price_date
                ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
            )
            *
            AVG(daily_return) OVER (
                PARTITION BY company_id
                ORDER BY price_date
                ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
            )
        )
    ) AS vol_2
FROM v_equity_returns
WHERE daily_return IS NOT NULL;

SELECT *
FROM v_vol_2
ORDER BY company_id, price_date;

DELETE FROM watchlist;

INSERT INTO watchlist (company_id, company_name, price_date, debt_to_market_cap, vol_2, risk_flag, rule_trigger)
SELECT
    l.company_id,
    l.company_name,
    l.price_date,
    l.debt_to_market_cap,
    v.vol_2,
    CASE
        WHEN l.debt_to_market_cap > 0.9 OR v.vol_2 > 0.04 THEN 'RISKY'
        ELSE 'OK'
    END AS risk_flag,
    CASE
        WHEN l.debt_to_market_cap > 0.9 AND v.vol_2 > 0.04 THEN 'LEVERAGE+VOL'
        WHEN l.debt_to_market_cap > 0.9 THEN 'LEVERAGE'
        WHEN v.vol_2 > 0.04 THEN 'VOL'
        ELSE 'NONE'
    END AS rule_trigger
FROM v_leverage l
JOIN v_vol_2 v
    ON l.company_id = v.company_id
   AND l.price_date = v.price_date
WHERE l.as_of_date = '2025-12-31';

SELECT *
FROM watchlist
ORDER BY company_name, price_date;