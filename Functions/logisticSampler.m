function X = logisticSampler(n_samples, b0, b1)

% generate samples from the logistic functions for a tristable percept

sigmoid = @(x, b0, b1) 1 ./ (1 + exp(-b1 * (x - b0)));

X = zeros(n_samples, 2);
X(:, 1) = rand(n_samples, 1);
X(:, 2) = 100; % 'coherence'

th(:, 1) = sigmoid(X(:, 1), b0, b1);
th(:, 2) = sigmoid(1 - X(:, 1), b0, b1);
th = cumsum(th, 2);
dummy = rand(n_samples, 1);

X(dummy <= th(:, 1), 2) = 10;
X(dummy > th(:, 1) & dummy <= th(:, 2), 2) = 1;