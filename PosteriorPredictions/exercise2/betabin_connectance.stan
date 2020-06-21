data{
    int W;
    int L[W];
    int S[W];
}
transformed data{
    int F[W];
    int R[W];
    int M[W];
    for ( i in 1:W ) {
        M[i] = S[i] - 1;
        F[i] = S[i] * S[i] - M[i];
        R[i] = L[i]        - M[i];
    }
}
parameters{
    real<lower=0,upper=1> mu;
    real phi;
}
model{
    phi ~ normal( 3,0.5 );
    mu ~ beta( 3 , 7 );
    for (i in 1:W){
       target += beta_binomial_lpmf(  R[i] | F[i] ,  mu * exp(phi) , (1 - mu) * exp(phi));
    }
}
generated quantities{
    vector[W] log_lik;
    vector[W] y_hat;
    for ( i in 1:W ) {
        log_lik[i] = beta_binomial_lpmf( R[i] | F[i] , mu * exp(phi), (1 - mu) * exp(phi)  );
        y_hat[i] = beta_binomial_rng(F[i] , mu * exp(phi), (1 - mu) * exp(phi) ) + M[i];
    }
}
