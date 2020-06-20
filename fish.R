library(ggplot2)
library(tidyverse)
library(magrittr)
library(brms)
library(tidybayes)

#data from https://www.kaggle.com/aungpyaeap/fish-market

fish <- read_csv("https://raw.githubusercontent.com/aammd/ISEC_stan_course/master/Fish.csv")
glimpse(fish)

fish %>% 
  ggplot(aes(x = Height, y = Weight)) + geom_point() +
  facet_wrap(~Species)

names(fish)

fish$xsection <- (fish$Height/2)^2
glimpse(fish)


# bayesian model with brms ------------------------------------------------


# create nonlinear model
# a varie en fonction d'espece!
fishtubes <- bf(Weight ~ a * (Height/2)^2,
                a ~ 1 + (1|Species),
                nl = TRUE, 
                family = gaussian())

get_prior(fishtubes, data = fish)

fish_prior <- c(
  prior(cauchy(0,2), class = "sigma"),
  prior(normal(2,2), class = "b", coef = "Intercept", nlpar = "a"),
  prior(cauchy(0,2), class = "sd", nlpar = "a")
)

ft_model_prior <- brm(fishtubes,
                      data = fish, 
                      prior = fish_prior,
                      sample_prior = "only")

fish %>% 
  add_predicted_draws(ft_model_prior, n = 12) %>% 
  ggplot(aes(x = Height, y = .prediction)) + 
  geom_point(alpha = 0.4) + 
  facet_wrap(~.draw)



#### End day 1! ################


## fit the model for real
ft_model <- brm(fishtubes, data = fish, prior = fish_prior, sample_prior = "yes")

fake_fish <- expand_grid(Height = seq(min(fish$Height),
                                      to = max(fish$Height), length.out = 200),
                         Species = unique(fish$Species))

fake_fish %>% 
  add_predicted_draws(ft_model, n = 500) %>% 
  ggplot(aes(x = Height, y = .prediction)) + 
  stat_lineribbon() + 
  geom_point(aes(y = Weight), data = fish, pch = 21, fill = "Orange") + 
  scale_fill_brewer(palette = "Greens") +
  facet_wrap(~Species)


## the range of the x is so different between panels! 

narrow_range_fish <- fish %>% 
  group_by(Species) %>% 
  summarize(min = min(Height),
            max = max(Height)) %>% 
  mutate(Height = map2(min, max, ~ seq(from = .x, to = .y, length.out = 100))) %>% 
  unnest(Height)


narrower_range_predicted_fish <-  narrow_range_fish %>% 
  add_predicted_draws(ft_model, n = 400)

normal_fish <- narrower_range_predicted_fish %>% 
  ggplot(aes(x = Height, y = .prediction)) + 
  stat_lineribbon() + 
  geom_point(aes(y = Weight), data = fish, pch = 21, fill = "Orange") + 
  scale_fill_brewer(palette = "Greens") +
  facet_wrap(~Species)

## not a bad model, but still improvements are possible! for example, negative
## predictions are very possible


# simplify code with functions! -------------------------------------------

plot_model_predictions <- function(model, df = narrow_range_fish){
  narrower_range_predicted_fish <-  df %>% 
    add_predicted_draws(model, n = 400)
  
  narrower_range_predicted_fish %>% 
    ggplot(aes(x = Height, y = .prediction)) + 
    stat_lineribbon() + 
    geom_point(aes(y = Weight), data = fish, pch = 21, fill = "Orange") + 
    scale_fill_brewer(palette = "Greens") +
    facet_wrap(~Species)
}




# gamma -------------------------------------------------------------------
fishtubes_gamma <- bf(Weight ~ a * (Height/2)^2,
                      a ~ 1 + (1|Species),
                      nl = TRUE, 
                      # specify the family -- NOTE THE LINK
                      family = Gamma(link = "identity")
)


get_prior(fishtubes_gamma, data = fish)

fish_prior_gamma <- c(
  prior(gamma(0.01,0.01),class="shape"),
  prior(normal(0, 0.5), class = "b", coef = "Intercept", nlpar = "a"),
  prior(normal(0,2), class = "sd", nlpar = "a")
)


#oops! there is one weight of zero!
sum(fish$Weight == 0)

fish_nozero <- fish %>% 
  filter(Weight > 0)
nrow(fish_nozero)
nrow(fish)

gamma_fish_fit <- brm(fishtubes_gamma, data = fish_nozero, prior = fish_prior_gamma, sample_prior = "yes")

gamma_plot <- plot_model_predictions(gamma_fish_fit) + 
  labs(y = "Weight (g)", x = "Height")

library(patchwork)
normal_fish + gamma_plot


ggsave("fish_predictions_mixed.png", height = 7, width = 8)


# model comparison --------------------------------------------------------

## first refit to a smaller dataset!
ft_model_nozero <- update(ft_model, newdata = fish_nozero)

normal_fish_waic <- loo(ft_model_nozero)

gamma_fish_waic <- loo(gamma_fish_fit)

loo_compare(normal_fish_waic, gamma_fish_waic)

## model averaging

combined_model <- pp_average(ft_model_nozero, gamma_fish_fit, newdata = narrow_range_fish)

narrow_range_fish %>% 
  cbind(combined_model %>% tibble)
