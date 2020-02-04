
% g = .35;
% r = .35;
% alpha = [.9, .1];
% bg = 128;
% 
% C = r/4 * ((1-g/bg) * (prod(alpha) * r - sum(alpha)) + 1/r);
% C = .1704;
% 
% G = (1 - (4*C-1) / (prod(alpha) * r^2 - sum(alpha) * r)) * bg;


function [lum, contrast] = fLuminanceContrast(Alpha, bg, g, r)

% if length(varargin) < 1,
%     bg = .5;
% end
% if length(varargin) < 2,
%     g = .35;
% end
% if length(varargin) < 3,
%     r = .35;
% end

% S = sum(Alpha); P = prod(Alpha);
% lum = bg + r * (P * r - S) * (bg - g);
% 
% contrast = r^2 * ((1+ P - S) * bg + (S - P) * g)^2 + ...
%     (1-r) * r * (((bg + Alpha(1) * (g - bg))^2 + (bg + Alpha(2) *(g - bg))^2 )) + ...
%     (1-r)^2 * bg^2 - lum^2;
% 
% 
% contrast = sqrt(contrast);


S = sum(Alpha, 2); P = prod(Alpha, 2);
lum = bg + r * (P .* r - S) * (bg - g);

contrast = r^2 * ((1+ P - S) * bg + (S - P) * g).^2 + ...
    (1-r) * r * (((bg + Alpha(:,1) * (g - bg)).^2 + (bg + Alpha(:,2) * (g - bg)).^2 )) + ...
    (1-r)^2 * bg^2 - lum.^2;


contrast = sqrt(contrast);
