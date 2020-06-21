## Eight schools data` `

y <- c(28,  8, -3,  7, -1,  1, 18, 12)
sigma <- c(15, 10, 16, 11,  9, 11, 10, 18)
standata <- list(y =y, sigma = sigma,J=length(y))

model_code <- "
data {
  int<lower=0> J;
  vector[J] y;
  vector[J] sigma;
}
parameters {
vector[J] theta;
real mu;
real<lower = 0> tau;
}
model {
  y ~ normal(theta, sigma);
  theta ~ normal(mu, tau);
  mu ~normal(0, 3);
  tau ~ normal(0, 3);
}
"
library(rstan)
stan_data <- list(y = y, sigma = sigma, J = length(y))
fit <- stan(model_code = model_code, data = stan_data)
## BAD

## Attempt 2!


model_code2 <- "
data {
int<lower=0> J;
vector[J] y;
vector[J] sigma;
}
parameters {
vector[J] z;
real mu;
real<lower = 0> tau;
}
transformed parameters {
// ANY TRANSFORMATION OF PARAMETERS GOES HERE!!!!!
  vector[J] theta = mu + tau*z;
}
model {
y ~ normal(theta, sigma);
z ~ normal(0, 1);
mu ~normal(0, 3);
tau ~ normal(0, 3);
}
"
fit2 <- stan(model_code = model_code2, data = stan_data)
print(fit2)
