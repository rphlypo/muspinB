%% Alpha selector
function [next_alpha] = AlphaEqSelect(alpha_equ)
% chose which side of .5
selector = rand;
if selector > .5
    alpha_picked = alpha_equ(2);
else
    alpha_picked = alpha_equ(1);
end
% Sample
m = alpha_picked; sd = .05;
next_alpha = m + sd.*randn;