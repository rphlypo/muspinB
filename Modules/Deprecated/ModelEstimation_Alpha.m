% Script for model estimation based on 1st percept data
% created on 18/06/2018
% by Kevin Parisot
% v1
function [next_alpha, alpha_equ] = ModelEstimation_Alpha(x_obs, y_obs)
METHOD = 2;
switch METHOD
    case 1
%% Discretize in percepts : 
% for i = 1 : length(y_obs)
%     if y_obs(i) < 1
%         y_obs_d = ;
%     elseif y_obs(i) < 2 && y_obs(i) >= 1
%         y_obs_d = ;
%     elseif y_obs(i) >= 2
%         y_obs_d = ;
%     end
% end
%% Estimate model of one percept
sigfunc = @(b, x)(1 ./ (1 + exp(-b(1) .* (x - b(2)))));
% estimation
b0 = ones(1,2);
b_fit = nlinfit(x_obs, y_obs, sigfunc, b0);

    case 2
        
end

%% Obtain equiprobable alpha given these parameter values
a = b_fit(1);
b = b_fit(1).*b_fit(2) - (b_fit(1)./2);
if b <= log(2)
    fprintf('Parameters are not good\n')
    return
end
alpha_eq = (1/2) + (acosh(exp(b) - 2.*exp(-b)) ./ a);

%% Once alpha_eq is found, sample gaussianly around it/them
alpha_diff = alpha_eq - .5;
alpha_equ = [.5 - alpha_diff, .5 + alpha_diff];
% chose which side of .5
selector = rand;
if selector > .5
    alpha_picked = alpha_equ(2);
else
    alpha_picked = alpha_equ(1);
end
% Sample
m = alpha_picked; sd = .1;
next_alpha = m + sd.*randn;