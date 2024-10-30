MSE(y...) = mean((diff(y...)).^2)

RMSE(y...) = √MSE(diff(y...))

MAE(y...) = mean(abs.(diff(y...)))
