function [rho, ix, alpha] = fmaxcorrangle(ref,test)


ref = bsxfun(@minus, ref, mean(ref, 1));
test = bsxfun(@minus, test, mean(test, 1));

R = test.'*ref;
alpha = atan((R(1,2) + R(2,1)) / (R(1,1) - R(2,2))) / 2;

w = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];

rho = diag(w.'*R*w) ./ sqrt(diag(w.' * ref.'*ref * w).* diag(w.' * test.'*test * w));

%[rho, ix] = sort(abs(rho), 1, 'descend');
[rho, ix] = sort(rho, 1, 'descend');

end