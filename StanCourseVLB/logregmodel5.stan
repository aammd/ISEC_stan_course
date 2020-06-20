// The input data is a vector 'y' of length 'TT'.
data {
  int<lower=1> TT;
  int y[TT];
  
  int ncov;
  matrix[TT, ncov] x;
  
  vector[TT] bsize;
  vector[TT] sex;
  
  int nsharks;
  int sharkid[TT];
}

parameters {
  //real<lower=0, upper=1> p;
  vector[ncov] beta[nsharks];
  vector[3] alpha;
  
  real mu;
  real<lower=0> stdev;
  
}

model {
  
  // Priors
  mu ~ normal(0, 0.1);
  stdev ~ normal(0, 0.1); // by default, this is the half-normal (because stdev > 0)
  
  
  alpha[1] ~ normal(0, 0.5);
  alpha[2] ~ normal(0, 0.5);
  //values range from -40 to 40
  alpha[3] ~ normal(0, 0.1);
  
  for(n in 1:nsharks){
    beta[n] ~ normal(mu, stdev);
  }

 for(t in 1:TT){
   y[t] ~ bernoulli_logit(alpha[1] + alpha[2]*sex[t] + alpha[3]*bsize[t] + x[t]*beta[sharkid[t]]);
 }
 
}

