% Header script
% by Kevin Parisot
% on 12/06/2018
% v1
% v2 (05/09/2018) : headers for bottom pilots 2,3; aftereffect; and
% topdown
function [Exp] = Header(Exp)

% Exp.Type = 'TopDown'; Exp.Pilot = 0;
% Exp.Type = 'BottomUp'; Exp.Pilot = 3;
Exp.Type = 'AfterEffect'; Exp.Pilot = 2;
% Exp.Type = 'GazeEEG'; Exp.Pilot = 1;

switch Exp.Type
    case 'GazeEEG'
        Exp.Flags.LEARNON = 1;
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = 0;
        Exp.Flags.SAVE = 0;
        Exp.Flags.SAVEONTHEGO = 0;
        Exp.Flags.DUMMY = 0;
        Exp.Flags.KEYPRESSPERCEPT = 1;
        Exp.Flags.MOUSE = 0;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.VERSION = 1;
        Exp.Flags.EEG = 0;
    case 'TopDown'
        Exp.Flags.LEARNON = 1;
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = 0;
        Exp.Flags.SAVE = 1;
        Exp.Flags.SAVEONTHEGO = 1;
        Exp.Flags.DUMMY = 0;
        Exp.Flags.KEYPRESSPERCEPT = 1;
        Exp.Flags.MOUSE = 1;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.EEG = 0;
        
    case 'BottomUp'
        switch Exp.Pilot
            case 1 % to be debugged as of 09/12/2019
                Exp.Flags.LEARNON = 1;
                Exp.Flags.SIGMOIDESTIMATE = 0;
                Exp.Flags.EYETRACK = 0;
                Exp.Flags.SAVE = 0;
                Exp.Flags.SAVEONTHEGO = 0;
                Exp.Flags.DUMMY = 0;
                Exp.Flags.KEYPRESSPERCEPT = 0;
                Exp.Flags.MOUSE = 1;
                Exp.Flags.MOUSECLICKON = 1;
                Exp.Flags.SHUFFLING = 'None'; % 'None', 'Blocks' or 'Trials'
                Exp.Flags.VERSION = 1;
                Exp.Flags.EEG = 0;
                
            case 2
                Exp.Flags.LEARNON = 1;
                Exp.Flags.SIGMOIDESTIMATE = 0;
                Exp.Flags.EYETRACK = 0;
                Exp.Flags.SAVE = 1;
                Exp.Flags.SAVEONTHEGO = 1;
                Exp.Flags.DUMMY = 0;
                Exp.Flags.KEYPRESSPERCEPT = 1;
                Exp.Flags.MOUSE = 0;
                Exp.Flags.MOUSECLICKON = 0;
                Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
                Exp.Flags.VERSION = 2;
                Exp.Flags.EEG = 0;
            case 3
                Exp.Flags.LEARNON = 0;
                Exp.Flags.SIGMOIDESTIMATE = 0;
                Exp.Flags.EYETRACK = 0; % needs to change to 1
                Exp.Flags.SAVE = 1;
                Exp.Flags.SAVEONTHEGO = 1;
                Exp.Flags.DUMMY = 0;
                Exp.Flags.KEYPRESSPERCEPT = 1;
                Exp.Flags.MOUSE = 0;
                Exp.Flags.MOUSECLICKON = 0;
                Exp.Flags.SHUFFLING = 'Blocks'; % 'None', 'Blocks' or 'Trials'
                Exp.Flags.PREPILOT = 3;
                Exp.Flags.EEG = 0;
        end
    case 'AfterEffect'
        Exp.Flags.LEARNON = 1;
        Exp.Flags.SIGMOIDESTIMATE = 0;
        Exp.Flags.EYETRACK = 0;
        Exp.Flags.SAVE = 1;
        Exp.Flags.SAVEONTHEGO = 1;
        Exp.Flags.DUMMY = 0;
        Exp.Flags.KEYPRESSPERCEPT = 1;
        Exp.Flags.MOUSE = 0;
        Exp.Flags.MOUSECLICKON = 0;
        Exp.Flags.SHUFFLING = 'Trials'; % 'None', 'Blocks' or 'Trials'
        Exp.Flags.EEG = 0;
end
end