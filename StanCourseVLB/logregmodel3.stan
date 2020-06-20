// The input data is a vector 'y' of length 'TT'.
data {
  int<lower=1> TT;
  int y[TT];
  
  int ncov;
  matrix[TT, ncov] x;
  
  vector[TT] bsize;
  vector[TT] sex;
}

parameters {
  //real<lower=0, upper=1> p;
  vector[ncov] beta;
  vector[3] alpha;
}

model {
  
  // Priors
  beta ~ normal(0, 0.5);
  alpha[1] ~ normal(0, 0.5);
  alpha[2] ~ normal(0, 0.5);
  //values range from -40 to 40
  alpha[3] ~ normal(0, 0.1);
 
  y ~ bernoulli_logit(alpha[1] + alpha[2]*sex + alpha[3]*bsize + x*beta);
}

