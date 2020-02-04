function [output] = fConv_pix2deg(input, h, d, r)
%% convert pixels to visual degrees
% 
% h = 30; % Monitor heigh in cm
% d = 57; % Distance between monitor and participant in cm
% r = 768; % Vertical resolution of the monitor

%% calculate the number of degrees that correspond to a single pixel.
% this will generally be a very small value, something like 0.03.
deg_per_px = atan2d(.5*h, d) / (.5*r);
output = input * deg_per_px;
end