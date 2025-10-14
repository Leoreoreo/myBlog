# Load the package and data
library(faraway)
data(airquality)

# Fit the linear model
ozone.regress <- lm(Ozone ~ Wind + Temp + Solar.R, data = airquality)

# Plot residuals vs. fitted values
plot(fitted(ozone.regress), residuals(ozone.regress),
     main = "Residuals vs. Fitted Values",
     xlab = "Fitted Values",
     ylab = "Residuals")
# Add a horizontal line at y=0 for reference
abline(h = 0, col = "red", lty = 2)

# Sets the plotting area to have 3 rows and 1 column
par(mfrow = c(3, 1))

# Create the three separate scatter plots
plot(Ozone ~ Wind, data = airquality, main = "Ozone vs. Wind Speed")
plot(Ozone ~ Temp, data = airquality, main = "Ozone vs. Temperature")
plot(Ozone ~ Solar.R, data = airquality, main = "Ozone vs. Solar Radiation")

# Optional: Reset the plotting area to the default 1x1 layout
par(mfrow = c(1, 1))

# Create the transformed variable
airquality$sqrt_ozone <- sqrt(airquality$Ozone)

# Set the plotting area to have 3 rows and 1 column
par(mfrow = c(3, 1))

# Create the three separate scatter plots with the transformed response
plot(sqrt_ozone ~ Wind, data = airquality, main = "Sqrt(Ozone) vs. Wind Speed")
plot(sqrt_ozone ~ Temp, data = airquality, main = "Sqrt(Ozone) vs. Temperature")
plot(sqrt_ozone ~ Solar.R, data = airquality, main = "Sqrt(Ozone) vs. Solar Radiation")

# Reset the plotting area to the default 1x1 layout
par(mfrow = c(1, 1))


# Create the new variable with the logarithmic transformation
airquality$log_ozone <- log(airquality$Ozone)

# Set the plotting area to have 3 rows and 1 column
par(mfrow = c(3, 1))

# Create the three separate scatter plots with the transformed response
plot(log_ozone ~ Wind, data = airquality, main = "Log(Ozone) vs. Wind Speed")
plot(log_ozone ~ Temp, data = airquality, main = "Log(Ozone) vs. Temperature")
plot(log_ozone ~ Solar.R, data = airquality, main = "Log(Ozone) vs. Solar Radiation")

# Optional: Reset the plotting area to the default 1x1 layout
par(mfrow = c(1, 1))

ozone.regress.log <- lm(log(Ozone) ~ Wind + Temp + Solar.R, data = airquality)

# Create a histogram of the residuals from the transformed model
hist(residuals(ozone.regress.log),
     main = "Histogram of Residuals (Transformed Model)",
     xlab = "Residuals")

# Create a QQ plot of the residuals
qqnorm(residuals(ozone.regress.log))
qqline(residuals(ozone.regress.log), col = "red")


shapiro.test(residuals(ozone.regress.log))

# The Durbin-Watson test is in the 'car' package
install.packages("lmtest")
library(lmtest)
dwtest(ozone.regress.log)

# 2. Create a new data frame with the specific conditions
predict.data <- data.frame(Solar.R = 186, Wind = 10, Temp = 80)

# 3. Predict the 'log' of ozone using the transformed model
predicted_log_value <- predict(ozone.regress.log, newdata = predict.data)
print(round(predicted_log_value, 3))

# 4. Use the exponential function exp() to transform it back to the original ozone scale
predicted_ozone <- exp(predicted_log_value)

# Print the final, rounded answer
print(round(predicted_ozone, 3))
