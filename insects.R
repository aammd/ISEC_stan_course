
library(tidyverse)
library(brms)
library(tidybayes)


## prior predictions for a poisson GLM about .. maggots

# make up data (NOT used)

insect_data <- tibble(
  env = rnorm(250, mean = 0, sd = 1),
  abundance = rpois(250, exp(5 + 0.5 * env))
)

# define formula

insects_bf <- bf(abundance ~ 1 + env, family = poisson())

get_prior(insects_bf, data = insect_data)

insect_priors <- c(
  prior(normal(0,100), class = "b", coef = "env"),
  prior(normal(0,100), class = "Intercept")
)

insect_samples <- brm(insects_bf,
                      data = insect_data,  # does nothing
                      prior = insect_priors,
                      sample_prior = "only")

# look breifly at the Stan model output
insect_samples


# add draw predictions to raw data
insect_data_draws <- insect_data %>% 
  add_predicted_draws(insect_samples, n = 12)

# visualize
insect_data_draws %>% 
  filter(.draw == 9) %>% 
  ggplot(aes(x = env, y = .prediction)) + 
  geom_point(alpha = 0.4)


# for comparison, the planet Saturn weighs 5.7 * 10^29 grams
  
## Exercise! edit the code above and find your *own* appropriate priors. Bonus,
## count an animal or plant which is more relevant to you (or stay with insects
## even if that is not your specialty!)
