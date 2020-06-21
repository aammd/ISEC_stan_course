data{
    int W;
    int L[W];
    int S[W];
}
parameters{
    real<lower=0,upper=1> a;
    real phi;
}
model{
    vector[W] mu;
    phi ~ normal( 2 , 1 );
    a ~ beta( 3 , 7 );
    for ( i in 1:W ) {
        mu[i] = a * S[i]^2;
    }
    L ~ neg_binomial_2( mu , exp(phi) );
}
generated quantities{
    vector[W] log_lik;
    vector[W] mu;
    vector[W] y_hat;
    for ( i in 1:W ) {
        mu[i] = a * S[i];
        log_lik[i] = neg_binomial_2_lpmf( L[i] | mu[i] , exp(phi) );
        y_hat[i] = neg_binomial_2_rng(mu[i], exp(phi));
    }
}
