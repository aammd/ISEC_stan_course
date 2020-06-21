
library(rstan)
library("loo")
library("shinystan")
options(mc.cores = parallel::detectCores())

# read the data
webs <- readr::read_csv("https://raw.githubusercontent.com/PoisotLab/ms_straight_lines/master/data/network_data.dat")

pred <- dplyr::filter(webs, predation > 0)

## read models

betabin <- rstan::stan_model(file = "betabin_connectance.stan", save_dso = TRUE)
conscon <- rstan::stan_model(file = "constant_connect.stan", save_dso = TRUE)
lsslmod <- rstan::stan_model(file = "lssl.stan", save_dso = TRUE)
powrlaw <- rstan::stan_model(file = "stan/powerlaw_connectance.stan", save_dso = TRUE)

# create a list of arguments

predsmall = dplyr::filter(pred, links < 4e4)

d <- list(
  W = nrow(predsmall),
  L = predsmall$links,
  S = predsmall$nodes
)


# sample models -----------------------------------------------------------

betabin_samples <- rstan::sampling(betabin, data = d, iter = 2000, chains = 4)
conscon_samples <- rstan::sampling(conscon, data = d, iter = 2000, chains = 4)
lsslmod_samples <- rstan::sampling(lsslmod, data = d, iter = 2000, chains = 4)
powrlaw_samples <- rstan::sampling(powrlaw, data = d, iter = 2000, chains = 4)

obs_links <- d$L
shinystan::launch_shinystan(betabin_samples)

# calculate and compare LOO diagnostics -----------------------------------

# adapted from the LOO vignette
# https://mc-stan.org/loo/articles/loo2-with-rstan.html


# Extract pointwise log-likelihood
# using merge_chains=FALSE returns an array, which is easier to
# use with relative_eff()
betabin_log_lik <- extract_log_lik(betabin_samples, merge_chains = FALSE)

# as of loo v2.0.0 we can optionally provide relative effective sample sizes
# when calling loo, which allows for better estimates of the PSIS effective
# sample sizes and Monte Carlo error
betabin_r_eff <- relative_eff(exp(betabin_log_lik))

# preferably use more than 2 cores (as many cores as possible)
# will use value of 'mc.cores' option if cores is not specified
betabin_loo <- loo(betabin_log_lik, r_eff = betabin_r_eff)
print(betabin_loo)

plot(betabin_loo)

## constant connect

conscon_log_lik <- extract_log_lik(conscon_samples, merge_chains = FALSE)
conscon_r_eff <- relative_eff(exp(conscon_log_lik), cores = 4)
conscon_loo <- loo(conscon_log_lik, #r_eff = conscon_r_eff,
                   cores = 4)

## Power Law


powrlaw_log_lik <- extract_log_lik(powrlaw_samples, merge_chains = FALSE)
powrlaw_r_eff <- relative_eff(exp(powrlaw_log_lik), cores = 4)
powrlaw_loo <- loo(powrlaw_log_lik, r_eff = powrlaw_r_eff, cores = 4)


#lsslmod

lsslmod_log_lik <- extract_log_lik(lsslmod_samples, merge_chains = FALSE)
lsslmod_r_eff <- relative_eff(exp(lsslmod_log_lik), cores = 4)
lsslmod_loo <- loo(lsslmod_log_lik, r_eff = lsslmod_r_eff, cores = 4)


# compare -----------------------------------------------------------------


print(betabin_loo)
print(powrlaw_loo)
print(lsslmod_loo)
print(conscon_loo)

loo_compare(betabin_loo, powrlaw_loo,lsslmod_loo, conscon_loo)


loo_compare(list(
  betabin = betabin_loo,
  powrlaw = powrlaw_loo,
  lsslmod = lsslmod_loo,
  conscon = conscon_loo))



loo_compare(powrlaw_loo, conscon_loo, lsslmod_loo, betabin_loo)


# plotting loo values -----------------------------------------------------

plot(lsslmod_loo)

print(conscon_loo)

plot(betabin_loo)

cbind(predsmall, betabin_loo$pointwise) %>%
  ggplot(aes(x = nodes, y = elpd_loo)) + geom_point()

cbind(predsmall, powrlaw_loo$pointwise) %>%
  ggplot(aes(x = nodes, y = elpd_loo)) + geom_point()

list(betabin = betabin_loo$pointwise[,1],
     powrlaw = powrlaw_loo$pointwise[,1]) %>%
  bind_rows %>%
  add_column(S = predsmall$nodes) %>%
  pivot_longer(-S, names_to = "model", values_to = "elpd") %>%
  ggplot(aes(x = S, y = elpd)) + facet_wrap(~model) +
  geom_point()



# look at diagnostics in shinystan ----------------------------------------



shinystan::launch_shinystan(betabin_samples)

