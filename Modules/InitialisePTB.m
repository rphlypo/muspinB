% Initialise PTB

function [Exp, win] = InitialisePTB(Exp)

%% ------------------------------------------------------------------------
%               Setup defaults and unit color range
% -------------------------------------------------------------------------
PsychDefaultSetup(2);

% Select screen with maximum id for output window:
Exp.PTB.screenid = max(Screen('Screens'));

% Find the color values which correspond to white and black.
Exp.PTB.white=WhiteIndex(Exp.PTB.screenid);
Exp.PTB.black=BlackIndex(Exp.PTB.screenid);

% Round gray to integral number, to avoid roundoff artifacts with some
% graphics cards:
Exp.PTB.gray=round((Exp.PTB.white + Exp.PTB.black)/2);

% This makes sure that on floating point framebuffers we still get a
% well defined gray. It isn't strictly neccessary in this demo:
if Exp.PTB.gray == Exp.PTB.white
    Exp.PTB.gray = Exp.PTB.white / 2;
end
Exp.PTB.inc = Exp.PTB.white - Exp.PTB.gray;

%% ------------------------------------------------------------------------
%                               Open window
% -------------------------------------------------------------------------
PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
[win, Exp.PTB.winRect] = PsychImaging('OpenWindow', Exp.PTB.screenid, Exp.Visual.Common.bckcol);
% [win, Exp.PTB.winRect] = Screen('OpenWindow',  Exp.PTB.screenid, Exp.Visual.Common.bckcol);

% Retrieve size of window in pixels, need it later to make sure that our
% moving gabors don't move out of the visible screen area:
[Exp.PTB.w, Exp.PTB.h] = RectSize(Exp.PTB.winRect);

% Query frame duration: We use it later on to time 'Flips' properly for an
% animation with constant framerate:
Exp.PTB.ifi = Screen('GetFlipInterval', win);

% to see what's going on behind the oclusion:
% Screen('BlendFunction', win, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA);

% Size of support in pixels, derived from si:
Exp.PTB.tw = 2*Exp.Visual.Common.gratSize+1;
Exp.PTB.th = 2*Exp.Visual.Common.gratSize+1;


% Speed of gratings:
Exp.PTB.T = [rad2deg(atan2(.5*Exp.PTB.H, Exp.PTB.D)) / (.5*Exp.PTB.h), ...
    rad2deg(atan2(.5*Exp.PTB.W, Exp.PTB.D)) / (.5*Exp.PTB.w)];
Exp.PTB.display.dist = Exp.PTB.D;
Exp.PTB.display.width = Exp.PTB.W;
Exp.PTB.display.resolution(1) = Exp.PTB.w;
Exp.PTB.display.frameRate = 1/Exp.PTB.ifi;

Exp.PTB.SpeedInPix = (Exp.Visual.Grating(1).speed ./ Exp.PTB.T);% * Exp.PTB.ifi; % in pixel/sec  
Exp.PTB.SpeedInDeg(1) = pix2angle(Exp.PTB.display.width, Exp.PTB.display.resolution(1),Exp.PTB.display.dist, Exp.PTB.SpeedInPix(1));
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
    Exp.PTB.RDKSpeedInPix = (Exp.Parameters.CoherenceSpeed ./ Exp.PTB.T);    
    Exp.PTB.RDKSpeedInDeg(1) = pix2angle(Exp.PTB.display.width, Exp.PTB.display.resolution(1),Exp.PTB.display.dist, Exp.PTB.RDKSpeedInPix(2));
end

Exp.PTB.display.height = Exp.PTB.H;
Exp.PTB.display.resolution(2) = Exp.PTB.h;
Exp.PTB.SpeedInDeg(2) = pix2angle(Exp.PTB.display.height, Exp.PTB.display.resolution(2),Exp.PTB.display.dist, Exp.PTB.SpeedInPix(2));
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
    Exp.PTB.RDKSpeedInDeg(2) = pix2angle(Exp.PTB.display.height, Exp.PTB.display.resolution(2),Exp.PTB.display.dist, Exp.PTB.RDKSpeedInPix(2));
end
end