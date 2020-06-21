data { 
  int<lower = 0> N;
  int<lower = 0> p;
  int<lower = 0, upper =1> y[N];
  matrix[N,p] X;
}

parameters {
  vector[p] beta;
}
model {
  y ~ binomial(1, Phi(X*beta));
  beta ~ normal(0,3);
}
