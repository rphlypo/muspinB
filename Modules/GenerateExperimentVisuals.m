% GenerateExperimentVisuals
function Exp = GenerateExperimentVisuals(Exp)
%% Common:

% Background:
Exp.Visual.Common.bckcol = .35; % large background
Exp.Visual.Common.texcol = .65; % text color
Exp.Visual.Common.bckcol2 = .35 + .15; % background behind gratings
% Grating texture size:
Exp.Visual.Common.gratSizeDeg = 12; % in visual degrees
Exp.Visual.Common.gratSize = angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.gratSizeDeg); %400; % in pixels
% Number of Gratings
Exp.Visual.Common.nbGratings = 2;
% Aperture size:
Exp.Visual.Common.apSize = 200; %angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.apSizeDeg); %Exp.Visual.Common.gratSize/2; % radius in pixel
Exp.Visual.Common.apSizeDeg = pix2angle(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.apSize); % radius in degrees
% Gaze oval zone size:
Exp.Visual.Common.ovSizeDeg = 1.25; % in degrees
Exp.Visual.Common.ovSize = angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.ovSizeDeg); %40; %50;% radius in pixels
Exp.Visual.Common.ovcol = [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol]; % RGB
% Fixation dot size:
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
    Exp.Visual.Common.dotSize = 1; %2 radius in pixels
    Exp.Visual.Common.dotcol = ones(1, 3) * .5; % RGB
else
    Exp.Visual.Common.dotSize = 2; % radius in pixels
    Exp.Visual.Common.dotcol = ones(1, 3) * .7; % RGB
end
% Mouse response zone parameters:
Exp.Visual.Common.MouseRespOvalOffsetDeg = 2; % in degrees
Exp.Visual.Common.MouseRespOvalSize = Exp.Visual.Common.gratSize + angle2pix(Exp.PTB.W, Exp.PTB.res(1), Exp.PTB.D, Exp.Visual.Common.MouseRespOvalOffsetDeg); %40; 
Exp.Visual.Common.MouseRespOvalCol = ones(1, 3) * (Exp.Visual.Common.bckcol - 0); % exp? florian

% Egalisateur et controle de luminance et contraste 
% (calcul?s pour alphas = [.5 .5], bg=.5, g=.35 et r=.35):
Exp.Visual.Common.LuminanceRef = 0.4521; % ? changer au niveau du bckcol
Exp.Visual.Common.ContrastRef = 0.0426;

%% Grating1:
% contrast within gratings:
% if and(Exp.Pilot == 3, Exp.Flags.PREPILOT)
%     Exp.Visual.Grating(1).mean = .45;%Exp.Visual.Common.bckcol2;
% else
    Exp.Visual.Grating(1).mean = .35;
% end
% Exp.Visual.Grating(1).mean = 0;
Exp.Visual.Grating(1).standev = .15; % mean; B/W difference
% Speed of motion: (options: .5, 1, 2)
Exp.Visual.Grating(1).speed(1) = 1.5 ; % visual degrees per second
% Angle from verticle axis:
Exp.Visual.Grating(1).rotAngles(1) = 30;
% Transparency parameter:
Exp.Visual.Grating(1).globalAlpha(1) = .5;

% Frequency (or period?) of sin e grating:
Exp.Visual.Grating(1).freq = .01; % per pixel?
% Phase of underlying sine grating in degrees:
Exp.Visual.Grating(1).phase = 0;
% Dutycycle, relative size of white part of grating period:
Exp.Visual.Grating(1).dutycycle = .35;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
Exp.Visual.Grating(1).spatialconstant = 1;
% Contrast of grating:
Exp.Visual.Grating(1).contrast = 1;
% Aspect ratio width vs. height:
Exp.Visual.Grating(1).aspectratio = 0;

%% Grating2:
% contrast within gratings:
Exp.Visual.Grating(2).mean = Exp.Visual.Grating(1).mean;
Exp.Visual.Grating(2).standev = Exp.Visual.Grating(1).standev;
% Speed of motion:
Exp.Visual.Grating(2).speed = -Exp.Visual.Grating(1).speed; % visual degrees per second
% Angle from verticle axis:
% rotAngles(2) = -rotAngles(1);
Exp.Visual.Grating(2).rotAngles = -Exp.Visual.Grating(1).rotAngles;
% Transparency parameter:
Exp.Visual.Grating(2).globalAlpha = Exp.Visual.Grating(1).globalAlpha;
% Frequency (or period?) of sine grating:
Exp.Visual.Grating(2).freq = Exp.Visual.Grating(1).freq;
% Phase of underlying sine grating in degrees:
Exp.Visual.Grating(2).phase = 0;
% Dutycycle, relative size of white part of grating period:
Exp.Visual.Grating(2).dutycycle = Exp.Visual.Grating(1).dutycycle;

% Useless parameters:
% Spatial constant of the exponential "hull" (contrast within the grating?)
Exp.Visual.Grating(2).spatialconstant = 1;
% Contrast of grating:
Exp.Visual.Grating(2).contrast = 1;
% Aspect ratio width vs. height:
Exp.Visual.Grating(2).aspectratio = 0;

%% Lissajou parameters
if strcmp(Exp.Type, 'TopDown')
    Exp.Visual.Lissajou.amp = 20;
else
    Exp.Visual.Lissajou.amp = 0;
end
Exp.Visual.Lissajou.fv = .4;
Exp.Visual.Lissajou.fh = pi/7;
Exp.Visual.Lissajou.phase = 0;

end