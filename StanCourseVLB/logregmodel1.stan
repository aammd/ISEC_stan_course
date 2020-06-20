// The input data is a vector 'y' of length 'TT'.
data {
  int<lower=1> TT;
  int y[TT];
}

parameters {
  real<lower=0, upper=1> p;
}

model {
  p ~ uniform(0, 1);
  y ~ bernoulli(p);
}

