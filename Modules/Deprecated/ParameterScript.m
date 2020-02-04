%% Parameters Script
% by Kevin Parisot
% created on 10/01/2018
% last edited on 10/01/2018

%% Common:
% Background:
bckcol = .35; texcol = .5; bckcol2 = .35 + .15;
% Grating texture size:
gratSize = 400; % in pixels
% Aperture size:
apSize = gratSize/2;
% Gaze oval zone size:
ovSize = 40; %50;% in pixels
ovcol = [bckcol, bckcol, bckcol]; % RGB
% Gaussian Mask size for noise:
maskSize = .7 * ovSize;
% Cross size and color:
crosscol = .6; crossSize = 7;
% Fixation dot size:
dotSize = 2; % in pixels
dotnoiseSize = dotSize; % in pixels
dotcol = ones(1, 3) * .7; % RGB
dotnoisecol = ones(1, 3) * .7; % RGB

interFix_StimOnset_time = .500; % in seconds

%% Grating1:
% contrast within gratings:
m1 = .35;
sd1 = .15; % mean; B/W difference
% Speed of motion: (options: .5, 1, 2)
speed(1) = 1 ; % pixel per frame
% Angle from verticle axis:
rotAngles(1) = 30 ;
% Transparency parameter:
globalAlpha(1) = .5;

% Frequency (or period?) of sin e grating:
freq1 = .01; % per pixel?
% Phase of underlying sine grating in degrees:
phase1 = 0;
% Dutycycle, relative size of white part of grating period:
dc1 = .35;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
sc1 = 1;
% Contrast of grating:
contrast1 = 1;
% Aspect ratio width vs. height:
aspectratio1 = 0;

%% Grating2:
% contrast within gratings:
m2 = m1;
sd2 = sd1;
% Speed of motion:
speed(2) = -speed(1); % pixel per frame
% Angle from verticle axis:
% rotAngles(2) = -rotAngles(1);
rotAngles(2,:) = -rotAngles(1,:);
% Transparency parameter:
% globalAlpha(2) = globalAlpha(1);
% globalAlpha(2,:) = 1-globalAlpha(1,:);
globalAlpha(2,:) = globalAlpha(1,:);
% Frequency (or period?) of sine grating:
freq2 = freq1;
% Phase of underlying sine grating in degrees:
phase2 = 0;
% Dutycycle, relative size of white part of grating period:
dc2 = dc1;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
sc2 = 1;
% Contrast of grating:
contrast2 = 1;
% Aspect ratio width vs. height:
aspectratio2 = 0;

% Obtain noise levels for each trial in each condition following beta
% distribution:
BetaParams = [.25 , .25];
VN_int = [.01, .3];
NA_int = [.25, .75; .75, 1.25];

%% Keypress parameters:
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
spaceKey = KbName('space');

KeyList = [escapeKey, leftKey, rightKey, upKey, spaceKey];
