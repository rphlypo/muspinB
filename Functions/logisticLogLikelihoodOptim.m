function [b0, b1] = logisticLogLikelihoodOptim(X, varargin)

% optimise the logistic likelihood using Newton-Raphson with convex
% constraint set
%
% logisticLogLikelihoodOptim(X)
% logisticLogLikelihoodOptim(X, 'tol', 1e-12)
% logisticLogLikelihoodOptim(X, 'maxIter', 1e3)
% logisticLogLikelihoodOptim(X, 'bStart', [1; 10])

p = inputParser;

defaultMaxIter = 1e3;
defaultTol = 1e-12;
defaultBStart = [1; 10];

addRequired(p, 'X', @(x) isnumeric(x) && ismember(size(x, 2), [2, 3]));
addOptional(p, 'maxIter', defaultMaxIter, @(x) validateattributes(x, {'double'}, {'positive'}));
addOptional(p, 'tol', defaultTol, @(x) validateattributes(x, {'numeric'}, {'double'}));
addOptional(p, 'bStart', defaultBStart, @(x) isnumeric(x) && numel(x) == 2 && all(x(:) - [1/2; 0]>=0));

parse(p, X, varargin{:});
X = p.Results.X;
maxIter = p.Results.maxIter;
tol = p.Results.tol;
bStart = p.Results.bStart;

converged = false;

B = bStart(:)';
L = logisticLogLikelihood(X, B(end, 1), B(end, 2));
nbIter = 0;

b0 = B(end, 1);
b1 = B(end, 2);

H = logisticLogLikelihood(X, b0, b1, 2);
D = logisticLogLikelihood(X, b0, b1, 1);
% step = 1/max(eig(H)) * D; 
step = pinv(H) * D;

while true,
    if b0 > 1/2 && step(1) < 0,
        eta0 = (1/2 - b0) / step(1);
    else
        eta0 = +inf;
    end
    if b1 > 0 && step(2) < 0,
        eta1 = -b1 / step(2);
    else
        eta1 = +inf;
    end
    
    eta_max = min([eta0, eta1, .1]);
    
    proposition = B(end, :).' - eta_max * step; % step is sometimes complex... this makes the proposition fail
    % Kevin :
    if proposition(1) < .5;
        proposition(1) = .5;
    end
    if proposition(2) <= 0;
        proposition(2) = 1e-6;
    end
    L_prop = logisticLogLikelihood(X, proposition(1), proposition(2));
    
    while L_prop < L && eta_max > eps(1),
        eta_max = eta_max * 2 / sqrt(5);
        proposition = B(end, :).' - eta_max * step;
        % Kevin :
        if proposition(1) < .5;
            proposition(1) = .5;
        end
        if proposition(2) <= 0;
            proposition(2) = 1e-6;
        end
        L_prop = logisticLogLikelihood(X, proposition(1), proposition(2));
    end
    
    L = L_prop;
    B(end+1, :) = proposition;
    nbIter = nbIter + 1;
     
    b0 = B(end, 1);
    b1 = B(end, 2);
    
    H = logisticLogLikelihood(X, b0, b1, 2);
    D = logisticLogLikelihood(X, b0, b1, 1);
%     rcond(H)
    step = pinv(H) * D;
    
%     step = 1/max(eig(H)) * D; %pinv(H) * D;
    
    nbIter = nbIter + 1;
    
    if norm(eta_max * step) < tol,
        converged = true;
        break
    elseif nbIter > maxIter,
        break
    end
end  