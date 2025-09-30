data {
  int <lower = 1> n;
  vector[n] x;
  vector[n] y;
  real true_beta;
}
parameters {
  real beta;
}
model {
  y ~ normal(x * beta, 1);
  beta ~ normal(0, 1);
}
