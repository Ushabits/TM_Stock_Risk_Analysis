**Tata Motors Stock Risk Analysis**
This project conducts a risk analysis on Tata Motors stock (Ticker: TATAMOTORS.NS) using historical price data from Yahoo Finance over the past 10 years. It combines technical analysis, Value at Risk (VaR) estimation, and GARCH modeling to understand the stock's volatility and risk profile.

**Project Overview**
Fetches 10 years of historical stock data using quantmod.

**Plots stock price with technical indicators:**
1. 50-day and 200-day Simple Moving Averages (SMA)
2. Bollinger Bands
3. Relative Strength Index (RSI)
4. Moving Average Convergence Divergence (MACD)

**Calculates Value at Risk (VaR) at 95% confidence using:**
1. Historical method
2. Gaussian (normal) method
3. Modified (Cornish-Fisher expansion) method

**Fits a GJR-GARCH(1,1) model to log returns:**
1. Forecasts 10 days ahead conditional volatility.
2. Plots GARCH conditional volatility.
3. Checks residuals for autocorrelation.
4. Computes and plots a rolling 100-day historical VaR.
5. Compares GARCH volatility and rolling VaR visually.

**Tools and Libraries**
1. **quantmod:** Data acquisition and technical indicators
2. **PerformanceAnalytics:** VaR estimation
3. **rugarch:** GARCH model fitting and forecasting
4. **TTR:** Technical indicators (RSI, MACD, SMA, Bollinger Bands)
5. **lubridate:** Date manipulations
6. **forecast, zoo:** Time series modeling and rolling calculations

**Key Outputs**
1. Stock price chart with SMAs and Bollinger Bands
2. RSI and MACD indicators plots
3. VaR (Historical, Gaussian, Modified) values
4. GARCH(1,1) model summary, residual tests, and volatility plots
5. Rolling VaR chart comparison with GARCH volatility

**Future Improvements**
1. Extend to multi-asset portfolio risk analysis.
2. Incorporate other volatility models like EGARCH or APARCH.
3. Backtest VaR predictions for model validation.
4. Automate parameter selection for ARMA-GARCH models.
