% Script for model estimation based on 1st percept data
% created on 18/06/2018
% by Kevin Parisot
% v1
function [alpha_eq] = ModelEstimation(Obs)
%% Estimate model of one percept
[b_fit(2), b_fit(1)] = logisticLogLikelihoodOptim(Obs);

%% Obtain equiprobable alpha given these parameter values
a = b_fit(1);
b = b_fit(1).*b_fit(2) - (b_fit(1)./2);

alpha_eq = (1/2) + (acosh(exp(b) - 2.*exp(-b)) ./ a);


end