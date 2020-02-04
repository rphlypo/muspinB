%% Parameters Script
% by Kevin Parisot
% created on 10/01/2018
% last edited on 07/02/2018
function [] = GenerateExperimentalParametersStructure()
%% Common:
% Background:
Parameters.Common.bckcol = .35; 
Parameters.Common.texcol = .5; 
Parameters.Common.bckcol2 = .35 + .15;
% Grating texture size:
Parameters.Common.gratSize = 400; % in pixels
% Aperture size:
Parameters.Common.apSize = gratSize/2;
% Gaze oval zone size:
Parameters.Common.ovSize = 40; %50;% in pixels
Parameters.Common.ovcol = [bckcol, bckcol, bckcol]; % RGB
% Gaussian Mask size for noise:
Parameters.Common.maskSize = .7 * ovSize;
% Cross size and color:
Parameters.Common.crosscol = .6; crossSize = 7;
% Fixation dot size:
Parameters.Common.dotSize = 2; % in pixels
Parameters.Common.dotnoiseSize = dotSize; % in pixels
Parameters.Common.dotcol = ones(1, 3) * .7; % RGB
Parameters.Common.dotnoisecol = ones(1, 3) * .7; % RGB

Parameters.Common.interFix_StimOnset_time = .500; % in seconds

%% Grating1:
% contrast within gratings:
Parameters.Grating1.m1 = .35;
Parameters.Grating1.sd1 = .15; % mean; B/W difference
% Speed of motion: (options: .5, 1, 2)
Parameters.Grating1.speed(1) = 1 ; % pixel per frame
% Angle from verticle axis:
Parameters.Grating1.rotAngles(1) = 30 ;
% Transparency parameter:
Parameters.Grating1.globalAlpha(1) = .5;

% Frequency (or period?) of sin e grating:
Parameters.Grating1.freq1 = .01; % per pixel?
% Phase of underlying sine grating in degrees:
Parameters.Grating1.phase1 = 0;
% Dutycycle, relative size of white part of grating period:
Parameters.Grating1.dc1 = .35;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
Parameters.Grating1.sc1 = 1;
% Contrast of grating:
Parameters.Grating1.contrast1 = 1;
% Aspect ratio width vs. height:
Parameters.Grating1.aspectratio1 = 0;

%% Grating2:
% contrast within gratings:
Parameters.Grating2.m2 = m1;
Parameters.Grating2.sd2 = sd1;
% Speed of motion:
Parameters.Grating2.speed(2) = -Parameters.Grating1.speed(1); % pixel per frame
% Angle from verticle axis:
% rotAngles(2) = -rotAngles(1);
Parameters.Grating2.rotAngles(2,:) = -rotAngles(1,:);
% Transparency parameter:
% globalAlpha(2) = globalAlpha(1);
% globalAlpha(2,:) = 1-globalAlpha(1,:);
Parameters.Grating2.globalAlpha(2,:) = Parameters.Grating1.globalAlpha(1,:);
% Frequency (or period?) of sine grating:
Parameters.Grating2.freq2 = freq1;
% Phase of underlying sine grating in degrees:
Parameters.Grating2.phase2 = 0;
% Dutycycle, relative size of white part of grating period:
Parameters.Grating2.dc2 = dc1;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
Parameters.Grating2.sc2 = 1;
% Contrast of grating:
Parameters.Grating2.contrast2 = 1;
% Aspect ratio width vs. height:
Parameters.Grating2.aspectratio2 = 0;

%% Obtain noise levels for each trial in each condition following beta
% distribution:
Parameters.Noise.BetaParams = [.25 , .25];
Parameters.Noise.VN_int = [.01, .3];
Parameters.Noise.NA_int = [.25, .75; .75, 1.25];

%% Keypress parameters:
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
spaceKey = KbName('space');

Parameters.KeyList = [escapeKey, leftKey, rightKey, upKey, spaceKey];
end