%% Eye Link initialisation
% by Kevin Parisot
% created on 10/01/2018
% last edited on 10/01/2018
% v2 - 17/02/2019 : redesigned to fit Exp_vMulti for pilot 3

function [Exp, el] = ELInit(Exp, win)
%Screen settings
framerate = 1/Exp.PTB.ifi; %75;
screenWidth = Exp.PTB.W; %406;
screenHeight = Exp.PTB.H; %305;
screenDistance = Exp.PTB.D; %570;

%Number of sequence before new calibration
Exp.EyeLink.blockCalib=10;
%Number of sequence before drift correction
Exp.EyeLink.dCorr=5;

if Exp.EyeLink.gui_eye==0
    Exp.EyeLink.geye='LEFT';
elseif Exp.EyeLink.gui_eye==1
    Exp.EyeLink.geye='RIGHT';
else
    fprintf('Error, the guiding eye must be either 0 for left or 1 for right');
    out=1;
end


% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if EyelinkInit()~= 1
    'plant'
    return;
end

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(win);
el.backgroundcolour=Exp.Visual.Common.bckcol;
el.msgfontcolour=Exp.Visual.Common.texcol;%255;
el.calibrationtargetcolour=[0.5, 0.5, 0.5];
% el.timeOutFirst=8;%Time before recalibration during the transition gaze.

% %this is used to update the el structure after
% %the changes have been made to the el init defaultf
PsychEyelinkDispatchCallback(el);

% make sure that we get gaze data from the Eyelink
%Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
Eyelink('command', 'file_sample_data  = GAZE,AREA,STATUS,INPUT');
Eyelink('command', 'file_event_data = GAZE,AREA,VELOCITY,STATUS');
Eyelink('command', 'file_event_filter = LEFT,RIGHT,SACCADE,FIXATION,BLINK,MESSAGE,INPUT');


% make sure that we get event data from the Eyelink
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA,STATUS,INPUT');
Eyelink('command', 'link_event_data = GAZE,AREA,VELOCITY,STATUS');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,BLINK,SACCADE,FIXATION,INPUT');
%Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');

% open file to record data to
Exp.EyeLink.edfFile=strcat('S',Exp.EyeLink.nSuj,  '.edf');
f=1;
while exist(Exp.EyeLink.edfFile,'file')
    f=f+1;
    Exp.EyeLink.edfFile = strcat('S',Exp.EyeLink.nSuj,num2str(f),'.edf');
end
Eyelink('Openfile', Exp.EyeLink.edfFile);

%Messages d'en-tête
s = sprintf('SOFTWARE NAME : MATLAB R2015b');
Eyelink('Message', s);
s = sprintf('SOFTWARE VERSION : Release 2014-07-21');
Eyelink('Message', s);
s = sprintf('DISPLAY_COORDS 0 0 1280 1024 ');
Eyelink('Message', s);
s = sprintf('FRAMERATE %s Hz', num2str(framerate));
Eyelink('Message', s);
s = sprintf('SUBJECT NAME : %s', Exp.EyeLink.nom);
Eyelink('Message', s);
s = sprintf('SUBJECT SESSION : 1');
Eyelink('Message', s);
s = sprintf('SCREEN WIDTH : 1280');
Eyelink('Message', s);
s = sprintf('SCREEN HEIGHT : 1024');
Eyelink('Message', s);
s = sprintf('SCREEN PHYS DIMX MM : %s', num2str(screenWidth));
Eyelink('Message', s);
s = sprintf('SCREEN PHYS DIMY MM : %s', num2str(screenHeight));
Eyelink('Message', s);
s =sprintf('SCREEN DISTANCE MM : %s', num2str(screenDistance));
Eyelink('Message', s);
s =sprintf('CALIB OFF X : 0');
Eyelink('Message', s);
s =sprintf('CALIB OFF Y : 0');
Eyelink('Message', s);
s = sprintf('GUIDING EYE : %s', Exp.EyeLink.geye);
Eyelink('Message', s);

WaitSecs(0.05);
Eyelink('StartRecording');
WaitSecs(0.05);

Exp.EyeLink.eye_used = Eyelink('EyeAvailable');  % get eye that's tracked
%    returns 0 (LEFT_EYE), 1 (RIGHT_EYE) or 2 (BINOCULAR) depending on what data is
%   available returns -1 if none available.ONLY VALID AFTER STARTSAMPLES EVENT READ
if Exp.EyeLink.eye_used==2
    Exp.EyeLink.eye_used=Exp.EyeLink.geye;
else
    if Exp.EyeLink.eye_used==0
        if Exp.EyeLink.gui_eye ~=0%geye ~=0
            disp('AVAILABLE EYE AND GUIDING EYE ARE NOT THE SAME')
            closingProgram();
            Eyelink( 'Shutdown');
            return;
        end
    else
        if Exp.EyeLink.eye_used==1
            if Exp.EyeLink.gui_eye ~=1 %geye ~=1
                disp('AVAILABLE EYE AND GUIDING EYE ARE NOT THE SAME')
                closingProgram();
                Eyelink( 'Shutdown');
                return;
            end
        end
    end
end
WaitSecs(0.05);
Eyelink('StopRecording');
WaitSecs(0.05);




% HideCursor;
