library(PerformanceAnalytics)
library(quantmod)
library(rugarch)
library(lubridate)
library(TTR)
library(forecast)
# Get 10 years of data
getSymbols("TATAMOTORS.NS", from = Sys.Date() - years(10), src = "yahoo")

stock_data <- TATAMOTORS.NS
chartSeries(stock_data, name = "Tata Motors Stock Price", theme = chartTheme("white"))

# Add 50-day and 200-day Simple Moving Averages
addSMA(n = 50, col = "blue")
addSMA(n = 200, col = "red")

addBBands(n = 20, sd = 2)

price <- Cl(TATAMOTORS.NS)
returns <- dailyReturn(price, type = "log")

rsi <- RSI(Cl(stock_data), n = 14)
plot(rsi, main = "RSI - Tata Motors", col = "green")
abline(h = c(30, 70), col = "red", lty = 2)  # Oversold/Overbought zones

macd <- MACD(Cl(stock_data), nFast = 12, nSlow = 26, nSig = 9, maType = EMA)
plot(macd$macd, type = "l", col = "green", main = "MACD Line")
lines(macd$signal, col = "darkred")

VaR(returns, p = 0.95, method = "historical")  # 5% VaR (1-day)

VaR(returns, p = 0.95, method = "gaussian")

VaR(returns, p = 0.95, method = "modified")  # Cornish-Fisher expansion

spec <- ugarchspec(variance.model = list(model = "gjrGARCH", garchOrder = c(1,1)),
                   mean.model = list(armaOrder = c(1,1)),
                   distribution.model = "sstd")

garch_fit <- ugarchfit(spec, returns)

plot(garch_fit, which = "all")

summary(garch_fit)
Box.test(residuals(garch_fit),lag = 10,type = 'Lj')

garch_forecast <- ugarchforecast(garch_fit, n.ahead = 10)
sigma(garch_forecast)  # Forecasted vol for next 10 days

library(zoo)

returns <- dailyReturn(price, type = "log")

rolling_var <- rollapply(returns, width = 100, FUN = function(x) {
  PerformanceAnalytics::VaR(x, p = 0.95, method = "historical")
}, by.column = FALSE, align = "right")

plot(rolling_var, main = "Rolling 1-Day Historical VaR (95%) - Tata Motors",
     col = "darkred", ylab = "VaR", xlab = "Date")
abline(h = 0, col = "gray")

# Reuse the GARCH model from earlier
plot(sigma(garch_fit), main = "Conditional Volatility from GARCH(1,1)",
     col = "blue", ylab = "Volatility", xlab = "Date")

par(mfrow = c(2,1))
plot(rolling_var, main = "Rolling VaR (95%)", col = "darkred", ylab = "VaR")
plot(sigma(garch_fit), main = "GARCH(1,1) Volatility", col = "blue", ylab = "Volatility")
