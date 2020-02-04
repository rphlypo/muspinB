% Script for model estimation based on 1st percept data
% created on 10/07/2018
% by Kevin Parisot
% v2
% v3 11/10/2018 : return which algo was chosen for alpha decision
%                 changed conditions to estimate alpha eq

function [next_alpha, alpha_equ, algo_flag] = ModelEstimation_Alpha2(Obs, AlphaSamplingParam)

[b_fit(2), b_fit(1)] = logisticLogLikelihoodOptim(Obs);

%% Obtain equiprobable alpha given these parameter values
a = b_fit(1);
b = b_fit(1).*b_fit(2) - (b_fit(1)./2);
alpha_eq = (1/2) + (acosh(exp(b) - 2.*exp(-b)) ./ a);
% if or(b <= log(2), ...
%         b_fit(1)*b_fit(2) - b_fit(1)/2 > 1/2 && ...
%         1/2 + (acosh(exp(b_fit(1)*b_fit(2) - b_fit(1)/2) - 2*exp(-(b_fit(1)*b_fit(2) - b_fit(1)/2)))/ b_fit(1)) < .9)
if or(or(or(b <= log(2), alpha_eq < .5), alpha_eq > 1), isnan(alpha_eq))
    fprintf('Parameters are not good : taking random next alpha\n')
%     next_alpha = .5 + .1*randn;
    next_alpha = AlphaSamplingParam(1) + AlphaSamplingParam(2)*randn;
    alpha_equ = [.3, .7];
    algo_flag = 0;
else
    
%     alpha_eq = (1/2) + (acosh(exp(b) - 2.*exp(-b)) ./ a);
    
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
%     m = alpha_picked; sd = .1;
%     next_alpha = m + sd.*randn;
    next_alpha = alpha_picked + AlphaSamplingParam(2).*randn;
    algo_flag = 1;
end
% Exp.Parameters.AlphaSampling
% figure; plot(linspace(0,1,100), 1./(1+exp(-a.*(linspace(0,1,100)-(1/2)) + b)) ); hold on; plot(linspace(0,1,100), 1./(1+exp(a.*(linspace(0,1,100)-(1/2)) + b)) ); plot(linspace(0,1,100), 1 - ( 1./(1+exp(-a.*(linspace(0,1,100)-(1/2)) + b)))  - (1./(1+exp(a.*(linspace(0,1,100)-(1/2)) + b)) ));
