%% Gratings Texture generation script
% by Kevin Parisot
% created on 10/01/2018
% last edited on 10/01/2018

function [Exp, glsl] = GratingCreating(Exp, win)


% Create a special texture drawing shader for masked texture drawing:
glsl = MakeTextureDrawShader(win, 'SeparateAlphaChannel');

Exp.Stimulus.grat_bar1 = Exp.Visual.Grating(1).mean-Exp.Visual.Grating(1).standev .* ones(Exp.PTB.w, Exp.Visual.Grating(1).dutycycle * (1 / Exp.Visual.Grating(1).freq));
Exp.Stimulus.grat_bar2 = Exp.Visual.Grating(2).mean-Exp.Visual.Grating(2).standev .* ones(Exp.PTB.w, Exp.Visual.Grating(2).dutycycle * (1 / Exp.Visual.Grating(2).freq));

Exp.Stimulus.grat_bar1_tex = Screen('MakeTexture', win, Exp.Stimulus.grat_bar1, Exp.Visual.Grating(1).rotAngles);
Exp.Stimulus.grat_bar2_tex = Screen('MakeTexture', win, Exp.Stimulus.grat_bar2, Exp.Visual.Grating(2).rotAngles, [], [], 1, glsl);


%% Aperture and fixation object rectangles:
% Rectangle for fixation oval:
Exp.Stimulus.ovRect = [Exp.PTB.w/2-Exp.Visual.Common.ovSize, Exp.PTB.h/2-Exp.Visual.Common.ovSize, Exp.PTB.w/2+Exp.Visual.Common.ovSize, Exp.PTB.h/2+Exp.Visual.Common.ovSize];
% Rectangle for fixation dot:
Exp.Stimulus.dotRect = [Exp.PTB.w/2-Exp.Visual.Common.dotSize, Exp.PTB.h/2-Exp.Visual.Common.dotSize, Exp.PTB.w/2+Exp.Visual.Common.dotSize, Exp.PTB.h/2+Exp.Visual.Common.dotSize];

% Create a single  binary transparency mask and store it to a texture:
Exp.Stimulus.aperture=ones(Exp.PTB.h, Exp.PTB.w, 2) * Exp.Visual.Common.bckcol;

[x,y]=meshgrid(-Exp.PTB.w/2 : Exp.PTB.w/2-1, -Exp.PTB.w/2 : Exp.PTB.w/2-1);
aperture_temp = Exp.PTB.white * (1-(x.^2 + y.^2 <= Exp.Visual.Common.apSize^2));

Exp.Stimulus.aperture(:, :, 2) = aperture_temp(Exp.PTB.w/2-Exp.PTB.h/2 : Exp.PTB.w/2+Exp.PTB.h/2-1, :);
Exp.Stimulus.aperturetex=Screen('MakeTexture', win, Exp.Stimulus.aperture);


% Definition of the drawn rectangle on the screen:
dst2Rect=[0 0 Exp.Visual.Common.MouseRespOvalSize Exp.Visual.Common.MouseRespOvalSize];
Exp.Stimulus.dst2Rect=CenterRect(dst2Rect, Exp.PTB.winRect);
% Definition of the drawn rectangle on the screen:
dstRect=[0 0 Exp.Visual.Common.gratSize Exp.Visual.Common.gratSize];
Exp.Stimulus.dstRect=CenterRect(dstRect, Exp.PTB.winRect);
end