function d = logisticLogLikelihood(X, b0, b1, varargin)

% Log-likelihood under the logistic regression model for a tristable
% stimulus
%
% logisticLogLikelihood(X, theta)
% logisticLogLikelihood(X, theta, order)
%
%
% Arguments
% ---------
% X      : the data, organised as an array of size Ni x 3 where the columns
%           represent (alpha, percept, weight) where
%               * alpha in [0, 1]
%               * percept in {1, 10, 100} where 
%                     1: transparent left
%                    10: transparent right
%                   100: coherent
%               * weight > 0, which is either the number of percepts at
%                   this specific alpha, or a normalised probability
%           if the data is represented as a Ni x 2 array, all weights are
%           supposed 1.
%
% b0, b1 : the parameters in the sigmoid for transparent right percept
%                                                       1
%               p(Xi=r | alpha_i, theta) = ---------------------------
%                                          1 + exp(-b1 * (alpha - b0))
%
% order : the order of the derivative for optimisation purposes 
%           currently order must be in {0, 1, 2}
%           (default: 0)
%
% 
% Returns
% -------
% d     : the order derivative of the logistic regression logLikelihood 

% Check input arguments
p = inputParser;
addRequired(p, 'X', @(x) isnumeric(x) && ismember(size(x, 2), [2, 3]));                  
addRequired(p, 'b0', @(x) validateattributes(x, {'double'}, {'>=', 1/2}));
addRequired(p, 'b1', @(x) validateattributes(x, {'double'}, {'nonnegative'}));
          
defaultOrder = 0;               
addOptional(p, 'order', defaultOrder, @(x) isfloat(x) & ismember(x, [0, 1, 2]));
parse(p, X, b0, b1, varargin{:});
order = p.Results.order;

w = [2; 1];

percept = X(:, 2);
tl = percept == 1;
tr = percept == 10;
coh = percept == 100;

percepts = {'tl', 'tr', 'coh'};
alpha = struct();

nc = 0;

for jj = 1:length(percepts),
    alpha.(percepts{jj}) = X(eval(percepts{jj}), 1);
    if size(X, 2) == 3,
        weights.(percepts{jj}) = X(eval(percepts{jj}), 3);
    else
        weights.(percepts{jj}) = 1;
    end
end

if size(X,2) == 3,
    nc = sum(weights.coh);
else
    nc = length(alpha.coh);
end

switch order
    case 0,
        d = -logp(alpha.tr, b0, b1, weights.tr) - logp(1 - alpha.tl, b0, b1, weights.tl) - ...
            logp(alpha.coh, b0, b1, weights.coh) - logp(1 - alpha.coh, b0, b1, weights.coh) + ...
            logp(1, w(1) * b0, w(2) * b1, nc, -1);
    case 1,
        d = -dlogp(alpha.tr, b0, b1, weights.tr) - dlogp(1 - alpha.tl, b0, b1, weights.tl) - ...
            dlogp(alpha.coh, b0, b1, weights.coh) - dlogp(1 - alpha.coh, b0, b1, weights.coh) + ...
            w .* dlogp(1, w(1) * b0, w(2) * b1, nc, -1);
    case 2,
        d = -ddlogp(alpha.tr, b0, b1, weights.tr) - ddlogp(1 - alpha.tl, b0, b1, weights.tl) - ...
            ddlogp(alpha.coh, b0, b1, weights.coh) - ddlogp(1 - alpha.coh, b0, b1, weights.coh) + ...
            (w * w.') .* ddlogp(1, w(1) * b0, w(2) * b1, nc, -1);
end


% ---------- helper functions -----------------
function y = logp(alpha, b0, b1, w, s)
if nargin < 4, w=1; end
if nargin < 5, s=1; end
y = sum(w .* log(exp(-b1*(alpha - b0)) + s));

function y = dlogp(alpha, b0, b1, w, s)
if nargin < 4, w=1; end
if nargin < 5, s=1; end
e = exp(-b1*(alpha - b0));
e = e ./ (e + s);
y = [b1 * sum(w .* e); sum(w .* (b0 - alpha) .* e)];
    
function y = ddlogp(alpha, b0, b1, w, s)
if nargin < 4, w=1; end
if nargin < 5, s=1; end
e = exp(-b1*(alpha - b0));
e = e ./ (e + s); % problem : quand e = -s, on obtient un inf
e2 = e .* (1 - e);
ddb0 = b1^2 * sum(w .* e2);
ddb1 = sum(w .* (b0 - alpha).^2 .* e2);
d0d1 = sum(w .* e) + b1 * sum(w .* (b0 - alpha) .* e2);
y = [ddb0, d0d1; d0d1, ddb1];

