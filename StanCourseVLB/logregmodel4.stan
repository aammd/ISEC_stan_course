// The input data is a vector 'y' of length 'TT'.
data {
  int<lower=1> TT;
  int y[TT];
  
  int sexmissing[TT];
  int ncov;
  matrix[TT, ncov] x;
  
  vector[TT] bsize;
  vector[TT] sex;
}

parameters {
  //real<lower=0, upper=1> p;
  vector[ncov] beta;
  vector[3] alpha;
  real<lower=0, upper=1> pi;
}

model {
  
  // Priors
  beta ~ normal(0, 0.5);
  alpha[1] ~ normal(0, 0.5);
  alpha[2] ~ normal(0, 0.5);
  //values range from -40 to 40
  alpha[3] ~ normal(0, 0.1);
 
 for(t in 1:TT){
  if(sexmissing[t] == 1){
    target += log_mix(pi, 
                bernoulli_logit_lpmf(y[t] | alpha[1] + 
                    alpha[3]*bsize +
                    x[t]*beta), 
                bernoulli_logit_lpmf(y[t] | alpha[1] + 
                    alpha[2] + 
                    alpha[3]*bsize[t] +
                    x[t]*beta));
  } else {
    y[t] ~ bernoulli_logit(alpha[1] +
                    alpha[2]*sex[t] + 
                    alpha[3]*bsize[t] +
                    x[t]*beta);
  }
 }
}

