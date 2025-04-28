# Load libraries
library(PerformanceAnalytics)
library(quantmod)
library(rugarch)
library(lubridate)
library(TTR)
library(forecast)
library(zoo)

# Create directory for plots if it doesn't exist
if (!dir.exists("plots")) {
  dir.create("plots")
}

# Fetch 10 years of stock data
getSymbols("TATAMOTORS.NS", from = Sys.Date() - years(10), src = "yahoo")
stock_data <- TATAMOTORS.NS
price <- Cl(stock_data)
returns <- dailyReturn(price, type = "log")

# Plot stock chart with technical indicators
png("plots/stock_price_with_indicators.png", width = 1000, height = 600)
chartSeries(stock_data, name = "Tata Motors Stock Price", theme = chartTheme("white"))
addSMA(n = 50, col = "blue")
addSMA(n = 200, col = "red")
addBBands(n = 20, sd = 2)
dev.off()

# Plot RSI
rsi <- RSI(price, n = 14)
png("plots/rsi_plot.png", width = 1000, height = 600)
plot(rsi, main = "RSI - Tata Motors", col = "green")
abline(h = c(30, 70), col = "red", lty = 2)
dev.off()

# Plot MACD
macd <- MACD(price, nFast = 12, nSlow = 26, nSig = 9, maType = EMA)
png("plots/macd_plot.png", width = 1000, height = 600)
plot(macd$macd, type = "l", col = "green", main = "MACD Line")
lines(macd$signal, col = "darkred")
dev.off()

# Value at Risk Calculations (printed to console)
historical_var <- VaR(returns, p = 0.95, method = "historical")
gaussian_var <- VaR(returns, p = 0.95, method = "gaussian")
modified_var <- VaR(returns, p = 0.95, method = "modified")

cat("Historical VaR (95%):", historical_var, "\n")
cat("Gaussian VaR (95%):", gaussian_var, "\n")
cat("Modified VaR (95%):", modified_var, "\n")

# GARCH model fitting
spec <- ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1,1)),
                   mean.model = list(armaOrder = c(0,0)),
                   distribution.model = "sstd")
garch_fit <- ugarchfit(spec, returns)

# Plot GARCH model outputs
png("plots/garch_model_diagnostics.png", width = 1000, height = 800)
plot(garch_fit, which = "all")
dev.off()

# Summary printed to console
summary(garch_fit)
Box.test(residuals(garch_fit), lag = 10, type = 'Lj')

# GARCH Volatility forecast
garch_forecast <- ugarchforecast(garch_fit, n.ahead = 10)
forecasted_volatility <- sigma(garch_forecast)
print(forecasted_volatility)

# Rolling VaR plot
rolling_var <- rollapply(returns, width = 100, FUN = function(x) {
  PerformanceAnalytics::VaR(x, p = 0.95, method = "historical")
}, by.column = FALSE, align = "right")

png("plots/rolling_var_plot.png", width = 1000, height = 600)
plot(rolling_var, main = "Rolling 1-Day Historical VaR (95%) - Tata Motors",
     col = "darkred", ylab = "VaR", xlab = "Date")
abline(h = 0, col = "gray")
dev.off()

# GARCH Conditional Volatility Plot
png("plots/garch_conditional_volatility.png", width = 1000, height = 600)
plot(sigma(garch_fit), main = "Conditional Volatility from GARCH(1,1)",
     col = "blue", ylab = "Volatility", xlab = "Date")
dev.off()

# Combined Rolling VaR and GARCH Volatility
png("plots/combined_var_volatility.png", width = 1000, height = 800)
par(mfrow = c(2,1))
plot(rolling_var, main = "Rolling VaR (95%)", col = "darkred", ylab = "VaR")
plot(sigma(garch_fit), main = "GARCH(1,1) Volatility", col = "blue", ylab = "Volatility")
par(mfrow = c(1,1)) # Reset layout
dev.off()
