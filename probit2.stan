data { 
  int<lower = 0> N_pos;
  int<lower = 0> N_neg;
  int<lower = 0> p;
  int<lower = 0> pos_index[N_pos];
  int<lower = 0> neg_index[N_neg];
  matrix[N_neg + N_pos,p] X;
}

parameters {
  vector[p] beta;
  real<lower = 0> z_pos[N_pos];
  real<upper = 0> z_neg[N_neg];
}
transformed parameters {
  vector[N_neg + N_pos] z;
  z[pos_index] = to_vector(z_pos);
  z[neg_index] = to_vector(z_neg);
  }
model {
  z ~ normal(X * beta, 1);
  beta ~ normal(0,3);
}
