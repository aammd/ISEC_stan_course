// The input data is a vector 'y' of length 'TT'.
data {
  int<lower=1> TT;
  int y[TT];
  
  int ncov;
  matrix[TT, ncov + 1] x;
}

parameters {
  //real<lower=0, upper=1> p;
  vector[ncov + 1] beta;
}

model {
  //p ~ uniform(0, 1);
  beta ~ normal(0, 0.5);
  y ~ bernoulli_logit(x*beta);
}

