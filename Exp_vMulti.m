% MULTI EXPERIMENT script
% by Kevin Parisot
% on 12/06/2018
% v7 : multi-experiment script with header to select which expeirment to
% run
% v8 (09/07/2018): includes pilot 2 for bottom-up
% v9 (11/07/2018): includes motion after-effect
% v10 (23/07/2018): adding RDK
% v11 (11/10/2018): corrected bug in pilot 2 algorithm to estimate equi
% probable alphas
% v12 (09/11/2018): pilot 3 bottomup structure added
% v13 (12/02/2019): pilot 3 change of RDK function and addition of PREPILOT
% for pilot 3
% v14 (22/03/2019): convert all inputs into visual degrees and make pilot 3
% prepilot structure and paradigm
% v15 (04/04/2019): move calibration and drift procedures to after RDK
% generation; removed alpha mixing of RDK dots; remove systematic
% calibration
% v16 (13/06/2019): pilot 3.3 with restricted conditions
% v17 (09/12/2019): adding the 'final' experiment with EEG triggers

clear
close all
sca

addpath 'Modules'
addpath 'Functions'


%% Flags as option selectors
Exp = struct();
Exp = Header(Exp);

Exp.Flags
WaitSecs(3);

%% Start PTB

Screen('Preference', 'SkipSyncTests', 1);

CRS = ClockRandSeed();

%% Flag pre-requisits
if not(Exp.Flags.SAVE)
    PhaseString = 'TEST'; CondString = 'DUMMY';
elseif Exp.Flags.SAVE
    Exp.EyeLink.nSuj = input('Subject number : ', 's');
    Exp.EyeLink.nom = input('Subject name : ', 's');
    if Exp.Flags.EYETRACK
        Exp.EyeLink.gui_eye = input('Give the guiding eye : 0 for left, 1 for right : ');
    end
    Exp.EyeLink.PlaidOn = input('Plaid : ', 's');
    dataFileName = ['Exp_' Exp.Type '_' Exp.EyeLink.nom '_' Exp.EyeLink.nSuj '.mat']
end

if strcmp(Exp.Type, 'TopDown')
    if not(Exp.Flags.LEARNON)
        InertiaReferenceFinal = 20; % dummy value
    end
end

if Exp.Flags.EEG
    % with methods from Emmanuelle :
    initializeParallelPort
    % Triggers
    DefinitionTrigger
    
    % with methods from Bruce :
    DIO = digitalio('parallel','LPT1');
    hline = addline(DIO,[0:7],'out');
    putvalue(DIO, 0);
end

%% Generate experiment parameters

Exp = GenerateExperimentParameters(Exp);

%% Generate experiment structure

Exp = GenerateExperimentStructure(Exp);

%% Generate Grating texture

% Screen :
Exp.PTB.W=.0406;
Exp.PTB.H=.0305; % meters
Exp.PTB.D=.0570; % meters
Exp.PTB.res = [1280, 1024];

Exp = GenerateExperimentVisuals(Exp);

%% PTB initialisation

[Exp, win] = InitialisePTB(Exp);

% Keypress parameters:
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
spaceKey = KbName('space');
if strcmp(Exp.Type, 'AfterEffect')
    downKey = KbName('DownArrow');
    KeyList = [escapeKey, leftKey, rightKey, upKey, downKey, spaceKey];
else
    KeyList = [escapeKey, leftKey, rightKey, upKey, spaceKey];
end

if Exp.Flags.DUMMY
    keyCode = zeros(1,256);
end

%% Grating creating

[Exp, glsl] = GratingCreatingUpdating(Exp, win, 0);


%% Sigmoid estimator initialization
% Initialize variables and sigmoid function for psychometric estimation
if Exp.Flags.SIGMOIDESTIMATE
    [Exp] = SigmoidEstimatorInit(Exp);
end

%% Initialise Eyetracking
if Exp.Flags.EYETRACK
    [Exp, el] = ELInit(Exp, win);
end

%% Experiment text

Exp = PrepareExpText(Exp);

%% Start experiment
if strcmp(Exp.Type, 'BottomUp')
    DrawFormattedText(win, [Exp.Type ' ' num2str(Exp.Pilot)],'center','center',Exp.Visual.Common.texcol);
elseif strcmp(Exp.Type, 'AfterEffect')
    DrawFormattedText(win, ['Plaid'],'center','center',Exp.Visual.Common.texcol);
else
    DrawFormattedText(win, [Exp.Type],'center','center',Exp.Visual.Common.texcol);
end
vbl = Screen('Flip', win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME TITLE\n');
    Eyelink('Message',s);
end
fprintf('\nPress key when ready to launch.\n');
KbStrokeWait;

DrawFormattedText(win, Exp.Text.startingMsg,'center','center',Exp.Visual.Common.texcol);
vbl = Screen('Flip', win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME STARTING MSG\n');
    Eyelink('Message',s);
end
KbStrokeWait;

%% Initialisation

Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Query duration of monitor refresh interval:
Exp.PTB.ifi=Screen('GetFlipInterval', win);

waitframes = 1;
waitduration = waitframes * Exp.PTB.ifi;

% Perform initial Flip to sync us to the VBL and for getting an initial
% VBL-Timestamp for our "WaitBlanking" emulation:
Screen('FillRect',win, Exp.Visual.Common.bckcol, [0 0 Exp.PTB.w Exp.PTB.h]);
vbl = Screen('Flip', win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME INITIAL SYNC\n');
    Eyelink('Message',s);
end

% End of cycle temporal threshold. To ensure gratings repeat themselves
% smoothly without a noticable glitch:
thre = 1 / (abs(max(Exp.Visual.Grating(1).speed)) * min([Exp.Visual.Grating(1).freq, Exp.Visual.Grating(2).freq]));

HideCursor;
CALIBREATIONPENDING = 0;

if Exp.Flags.EEG && Exp.Flags.EYETRACK
    %-------------------------------------------------------------------------%
    %                   STARTING EEG                              %
    %-------------------------------------------------------------------------%
    MsgEEG='L''exp?rimentateur commence l''enregistrement EEG';
    Screen('FillRect', windowptr, basicFontColor);
    DrawFormattedText(windowptr, MsgEEG ,'center' , 'center',basicTextColor);
    Screen('Flip', windowptr );
    Eyelink('Message',['INPUT ' Trigger_BeginEndAcquitision ])
    fprintf(fileID,'INPUT %s \n',Trigger_BeginEndAcquitision);
    Eyelink('Message',['INPUT ' Trigger_BeginAcquisitionEEG ])
    fprintf(fileID,'INPUT %s \n',Trigger_BeginAcquisitionEEG );
    KbStrokeWait;
end

fprintf('\n --- Experimental loop will begin ---\n');


%%  EXPERIMENTAL LOOP
Exp.Current = struct();
trial_inExp_cnt = 0;
Durations = [];
for phase = 1 : Exp.Parameters.NumberOfPhases
    [Exp] = UpdateExpCurrent(Exp, 'Phase', phase);
    
    switch Exp.Current.Phase
        case 'LEARN'
            if strcmp(Exp.Type, 'AfterEffect')
                NbBlock = size(Exp.Parameters.LearnConditions, 1);
            else
                NbBlock = size(Exp.Parameters.LearnConditions, 2);
            end
        case 'TEST'
            NbBlock = Exp.Parameters.NumberOfBlocks;
            trial_inTest_cnt = 0;
            if strcmp(Exp.Type, 'AfterEffect')
                FirstPercDur = [];
                for t = 1 : Exp.Parameters.LengthOfBlocksLearn
                    temp = Exp.Data.LEARN.Trial(t).Perception;
                    temp(temp(:,1)==0,:) = [];
                    FirstPercDur = [FirstPercDur Exp.Data.LEARN.Trial(t).StimFinish - temp(1,2)];
                end
                %                 Exp.Parameters.TrialTimeOut = median(FirstPercDur);
            end
    end
    for block = 1 : NbBlock
        [Exp] = UpdateExpCurrent(Exp, 'Block', block);
        switch Exp.Current.Phase
            case 'LEARN'
                NbTrials = Exp.Parameters.LengthOfBlocksLearn;
            case 'TEST'
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
                    NbTrials = Exp.Parameters.LengthOfBlocks(block);
                else
                    NbTrials = Exp.Parameters.LengthOfBlocks;
                end
        end
                
        % Draw the background
        Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
        
        %% Draw text
        DrawFormattedText(win, ['Phase : ' Exp.Current.Phase '\n'],'center','center',Exp.Visual.Common.texcol);
        vbl = Screen('Flip', win);
        if Exp.Flags.EYETRACK
            s = sprintf('FLIP TRIAL STARTING MSG\n');
            Eyelink('Message',s);
        end
        if Exp.Flags.EEG % trial starting msg trigger
            
        end
        WaitSecs(1.5);
        
        BLOCK_ON = 1; trial = 0;
        
        % RONALD
        perceptDuration = [];
        
        while BLOCK_ON
            trial = trial + 1;
            trial_inExp_cnt = trial_inExp_cnt + 1;
            if strcmp(Exp.Current.Phase, 'TEST')
                trial_inTest_cnt = trial_inTest_cnt + 1;
                Update_cnt = [trial, trial_inTest_cnt, trial_inExp_cnt];
            else
                Update_cnt = [trial, NaN, trial_inExp_cnt];
            end
            
            %% Set trial parameters
            [Exp] = UpdateExpCurrent(Exp, 'Trial', Update_cnt);
            if isempty(Exp.Current.Condition)
                BLOCK_ON = 0;
            end
            [Exp] = GratingCreatingUpdating(Exp, win, [1, glsl]);
            
            % Draw the background
            Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
            
            
            
            %% Intializations:
            Looptimes = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
            mx = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
            my = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
            dotDisp = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),2);
            MouseTimes = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
            mpos = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),2);
            Inertia = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
            dev_cnt = zeros(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
            buttons = zeros(1,3); kpErr = 0;
            trial_response = nan(1,3);
            cycle = 0;
            Perception = nan(100,4); keyHasBeenPressed = 0; keyIsDown = 0;
            p=0;oldkeyCode=[];
            if Exp.Flags.DUMMY
                p_cnt = uint8(0);
            end
            LoopAlphas = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),2);
            if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition, 'Dynamic')
                LoopBackGround = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),1);
                Exp.Current.NextExoPerceptReversal = [];
                Exp.Current.NextPercept = [];
            end
            if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
                Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                DrawFormattedText(win, 'Chargement du prochain essai...', ...
                    'center','center',Exp.Visual.Common.texcol);
                vbl = Screen('Flip', win);
                % Let's determine the random walks of all the dots before
                % the loop starts
                %                 if Exp.Current.Condition == 'NoRDK'
                %                     [Exp.Current.Particles] = fDirectionRDK(1, Exp.Visual.Common.dotcol, Exp.Visual.Common.dotSize, [0,0],  [0,0], ...
                %                     Exp.PTB.RDKSpeedInDeg, Exp.Parameters.TrialTimeOut+1, Exp.Current.CohDir, Exp.Parameters.TrialTimeOut, 1-Exp.Current.CohPerc, Exp.PTB.display);
                %                 else
                [Exp.Current.Particles] = fDirectionRDK(Exp.Parameters.nDots, Exp.Visual.Common.dotcol, Exp.Visual.Common.dotSize, [0,0], Exp.Parameters.DotLimit, ...
                    Exp.PTB.RDKSpeedInDeg, Exp.Parameters.TrialTimeOut+1, Exp.Current.CohDir, Exp.Parameters.TrialTimeOut, 1-Exp.Current.CohPerc, Exp.PTB.display);
                %                 [Exp.Current.Particles] = fDirectionRDK(Exp.Parameters.nDots, Exp.Visual.Common.dotcol, Exp.Visual.Common.dotSize, [0,0], Exp.Parameters.DotLimit, ...
                %                     Exp.PTB.RDKSpeedInDeg, Exp.Parameters.TrialTimeOut+1, Exp.Current.BiasedPerceptDeg, Exp.Parameters.TrialTimeOut, 1-Exp.Current.CohPerc, Exp.PTB.display);
                %                 end
            end
            
            %% Drift & calibration procedure
            if Exp.Flags.EYETRACK
                if trial == 1 %rem(trial,5) == 0 && not(trial == NbTrials)
                    % Calibration
                    fprintf('Calibration\n');
                    Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                    DrawFormattedText(win, 'Calibration','center','center',Exp.Visual.Common.texcol);
                    vbl = Screen('Flip', win);
                    s = sprintf('FLIP FRAME CALIBRATION\n');
                    Eyelink('Message',s);
                    WaitSecs(3);
                    
                    s = sprintf('BEGIN CALIBRATION BY PERIOD\n');
                    Eyelink('Message', s);
                    EyelinkDoTrackerSetup(el, 'c');
                    
                    Eyelink('StartRecording');
                    
                    statusError=Eyelink('CheckRecording');
                    if (statusError~=0)
                        %gratingDisp ('Error writing data file');
                        Screen('closeall');
                        status=Eyelink('isconnected');
                        if status        % if not connected
                            Eyelink('closefile');
                            WaitSecs(1.0); % give tracker time to execute all commands
                            Eyelink('shutdown');
                        end
                        ShowCursor;
                        return;
                    end
                else
                    % Drift
                    Eyelink('StopRecording');
                    
                    % Draw the perceived background
                    Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                    DrawFormattedText(win, Exp.Text.driftCorrectionMsg,'center','center',Exp.Visual.Common.texcol);
                    vbl = Screen('Flip', win);
                    s = sprintf('FLIP FRAME DRIFT MSG\n');
                    Eyelink('Message',s);
                    WaitSecs(2);
                    
                    s = sprintf('BEGIN DRIFT BY PERIOD\n');
                    Eyelink('Message', s);
                    EyelinkDoDriftCorrect(el);
                    fprintf('Drift\n');
                    Eyelink('StartRecording');
                end
            end
            
            %% Draw text
            DrawFormattedText(win, Exp.Current.Text,'center','center',Exp.Visual.Common.texcol);
            vbl = Screen('Flip', win);
            if Exp.Flags.EYETRACK
                s = sprintf('FLIP TRIAL STARTING MSG\n');
                Eyelink('Message',s);
            end
            
            %                 KbStrokeWait;
            WaitSecs(.5);
            WAITING = 1;
            while WAITING
                [keyIsDown, secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    fprintf('Experiment stopped because of escape\n');
                    if Exp.Flags.EYETRACK
                        s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                        Eyelink('Message',s);
                    end
                    ShowCursor;
                    
                    if Exp.Flags.EYETRACK
                        s = sprintf('END PHASE\n');
                        Eyelink('Message', s);
                        
                        s = sprintf('END ACQUISITION\n');
                        Eyelink('Message',s);
                        
                        WaitSecs(0.1);
                        Eyelink('StopRecording');
                        Eyelink('CloseFile');
                        if Exp.Flags.SAVE
                            % save el data file
                            try
                                fprintf('Receiving data file ''%s''\n', Exp.EyeLink.edfFile );
                                status=Eyelink('ReceiveFile');
                                if status > 0
                                    fprintf('ReceiveFile status %d\n', status);
                                end
                                if 2==exist(Exp.EyeLink.edfFile, 'file')
                                    fprintf('Data file ''%s'' can be found in ''%s''\n', Exp.EyeLink.edfFile, pwd );
                                end
                            catch err
                                fprintf('Problem receiving data file ''%s''\n', Exp.EyeLink.edfFile );
                                psychrethrow(err);
                            end
                        end
                        
                        WaitSecs(0.1);
                        Eyelink('ShutDown');
                        
                    end
                    
                    if Exp.Flags.SAVE
                        save(dataFileName, 'Exp');
                    end
                    
                    sca;
                    return
                elseif or(or(or(keyCode(spaceKey), keyCode(leftKey)), keyCode(rightKey)), keyCode(upKey))
                    WAITING = 0;
                end
            end
            
            %% Fixation dot presentation
            FIXDOT_PRES = 1;
            count_down = ceil(Exp.Current.FixPointJit * (1/Exp.PTB.ifi));
            cnt = 1;
            while FIXDOT_PRES
                HideCursor;
                % Draw the perceived background
                Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                
                % Draw normal oval:
                Screen('FillOval', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol 255], Exp.Stimulus.ovRect);
                Screen('DrawDots', win, [Exp.PTB.w/2 Exp.PTB.h/2], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
                vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * Exp.PTB.ifi);
                
                if Exp.Flags.EYETRACK
                    s = sprintf('FLIP FRAME %s\n',num2str(cnt));
                    Eyelink('Message',s);
                end
                if Exp.Flags.EEG % fixation flip frame trigger
                    putvalue(DIO,31); % Data Acquisition Toolbox
                end
                count_down = count_down - 1;
                if count_down < 0
                    FIXDOT_PRES = 0;
                end
            end
            
            %% Animation loop
            % Initialisations:
            TRIAL_ON = 1;
            BUTTON_TIMEOUT_STARTED = 0;
            WAITINGPERCEPTREVERSAL = 0;
            MANIPON = 0;
            MOTION = 1; NEEDNEWPERCEPT = 1;
            if strcmp(Exp.Type, 'AfterEffect')
                WAITINGTOFREEZE = 1;
            end
            count_down = ceil(Exp.Parameters.TrialTimeOut * (1/Exp.PTB.ifi));
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart = GetSecs;
            
            % Here we set the initial position of the mouse to be in the centre of the
            % screen
            SetMouse(Exp.PTB.w/2, Exp.PTB.h/2, win);
            %             ShowCursor;
            
            %% Stimulus presentation loop
            % RONALD
            PureStates = [0, GetSecs]; % local variable for trial
            
            while TRIAL_ON
                loopst = GetSecs;
                
                % Set angles of gratings for this loop:
                Loop_Angle = [Exp.Current.BaseLineOrientation + Exp.Visual.Grating(1).rotAngles, ...
                    Exp.Current.BaseLineOrientation + Exp.Visual.Grating(2).rotAngles];
                
                % Set transparency values for this loop:
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
                    if WAITINGPERCEPTREVERSAL == 0
                        Exp.Current.NextExoPerceptReversal = [Exp.Current.NextExoPerceptReversal, 2 + (3-2) .* rand];
                        PerceptReversalCntDown = ceil(Exp.Current.NextExoPerceptReversal(end) * (1/Exp.PTB.ifi));
                        if not(isnan(Perception(2,1))) && NEEDNEWPERCEPT
                            fprintf('Time to find a percept\n')
                            if Perception(p,1) == 0
                                p_temp = p - 1;
                            else
                                p_temp = p;
                            end
                            switch Perception(p_temp,1)
                                case 1
                                    possibilities = [10, 100];
                                    Exp.Current.NextPercept = [Exp.Current.NextPercept, possibilities(randi(2))];
                                case 10
                                    possibilities = [1, 100];
                                    Exp.Current.NextPercept = [Exp.Current.NextPercept, possibilities(randi(2))];
                                case 100
                                    possibilities = [1, 10];
                                    Exp.Current.NextPercept = [Exp.Current.NextPercept, possibilities(randi(2))];
                            end
                            NEEDNEWPERCEPT = 0;
                            Loop_Alpha = LoopAlphas(cnt-1,:);
                        else
                            if Exp.Flags.VERSION == 2 && cnt > 1
                                Loop_Alpha = LoopAlphas(cnt-1,:);
                            else
                                Loop_Alpha = Exp.Current.Alphas;
                            end
                            % Adjust luminance and contrast depending on alphas picked:
                            [Loop_Luminance, Loop_Contrast] = fLuminanceContrast(Loop_Alpha, ...
                                Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
                            [Loop_BetaLum, Loop_OffsetLum] = fEgalisateur(Loop_Luminance, Loop_Contrast, ...
                                Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
                            Loop_GratingLum(1) = Loop_BetaLum * Exp.Visual.Grating(1).mean + Loop_OffsetLum;
                            Loop_GratingLum(2) = Loop_BetaLum * Exp.Visual.Grating(2).mean + Loop_OffsetLum;
                            Loop_BackGround = Loop_BetaLum * Exp.Visual.Common.bckcol2 + Loop_OffsetLum;
                        end
                        WAITINGPERCEPTREVERSAL = 1;
                    else
                        PerceptReversalCntDown = PerceptReversalCntDown - 1;
                        %                         Loop_Alpha = Exp.Current.Alphas;
                        Loop_Alpha = LoopAlphas(cnt-1,:);
                        %                             fprintf('Hello?!\n')
                    end
                    if PerceptReversalCntDown <= 0 % let's manipulate the stim
                        if not(MANIPON)
                            manipCnt = 1;
                            MANIPON = 1;
                            %                             AlphaStart = LoopAlphas(cnt-1,:);
                            AlphaStart = Exp.Current.Alphas;
                            switch Exp.Flags.VERSION
                                case 2
                                    switch Exp.Current.NextPercept(end)
                                        case 1
                                            Steps_alpha = [linspace(AlphaStart(1), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==1,2), Exp.Parameters.ManipCntMax)', ...
                                                linspace(AlphaStart(2), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==1,3), Exp.Parameters.ManipCntMax)'];
                                        case 10
                                            Steps_alpha = [linspace(AlphaStart(1), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==10,2), Exp.Parameters.ManipCntMax)', ...
                                                linspace(AlphaStart(2), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==10,3), Exp.Parameters.ManipCntMax)'];
                                        case 100
                                            Steps_alpha = [linspace(AlphaStart(1), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==100,2), Exp.Parameters.ManipCntMax)', ...
                                                linspace(AlphaStart(2), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==100,3), Exp.Parameters.ManipCntMax)'];
                                    end
                                case 1
                                    switch Exp.Current.NextPercept(end)
                                        case 1
                                            Steps_alpha = [linspace(Exp.Current.Alphas(1), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==1,2), Exp.Parameters.ManipCntMax)', ...
                                                linspace(Exp.Current.Alphas(2), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==1,3), Exp.Parameters.ManipCntMax)'];
                                        case 10
                                            Steps_alpha = [linspace(Exp.Current.Alphas(1), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==10,2), Exp.Parameters.ManipCntMax)', ...
                                                linspace(Exp.Current.Alphas(2), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==10,3), Exp.Parameters.ManipCntMax)'];
                                        case 100
                                            Steps_alpha = [linspace(Exp.Current.Alphas(1), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==100,2), Exp.Parameters.ManipCntMax)', ...
                                                linspace(Exp.Current.Alphas(2), Exp.Current.AlphasPercept(Exp.Current.AlphasPercept(:,1)==100,3), Exp.Parameters.ManipCntMax)'];
                                    end
                            end
                            
                        end
                        
                        Loop_Alpha = Steps_alpha(manipCnt,:);
                        
                        manipCnt = manipCnt + 1;
                        if manipCnt == Exp.Parameters.ManipCntMax
                            %                             PERCEPTIONMANIPULATION = 0;
                            WAITINGPERCEPTREVERSAL = 0;
                            MANIPON = 0; NEEDNEWPERCEPT = 1;
                            %                             manipCnt = 1;
                            fprintf('EndM!\n')
                        end
                    elseif Exp.Flags.VERSION == 1 && not(PerceptReversalCntDown <= 0)
                        Loop_Alpha = Exp.Current.Alphas;
                        % Adjust luminance and contrast depending on alphas picked:
                        [Loop_Luminance, Loop_Contrast] = fLuminanceContrast(Loop_Alpha, ...
                            Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
                        [Loop_BetaLum, Loop_OffsetLum] = fEgalisateur(Loop_Luminance, Loop_Contrast, ...
                            Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
                        Loop_GratingLum(1) = Loop_BetaLum * Exp.Visual.Grating(1).mean + Loop_OffsetLum;
                        Loop_GratingLum(2) = Loop_BetaLum * Exp.Visual.Grating(2).mean + Loop_OffsetLum;
                        Loop_BackGround = Loop_BetaLum * Exp.Visual.Common.bckcol2 + Loop_OffsetLum;
                    end
                else
                    Loop_Alpha = Exp.Current.Alphas;
                    %                     Loop_Alpha = [1, 1];
                end
                
                LoopAlphas(cnt,:) = Loop_Alpha;
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
                    LoopBackGround(cnt) = Loop_BackGround;
                end
                % Compute displacement of gratings based on current time:
                TimeForMotion = mod(GetSecs - Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart, ...
                    (Exp.Visual.Common.apSize) / Exp.PTB.SpeedInPix(1));
                %                     (Exp.Visual.Common.apSizeDeg) / Exp.Visual.Grating(1).speed)
                
                if MOTION
                    gratingDisp = [TimeForMotion .* Exp.PTB.SpeedInPix(1), ...
                        TimeForMotion .* Exp.PTB.SpeedInPix(1) + Exp.Current.PhaseShift];
                    %                     [round(TimeForMotion .* Exp.PTB.SpeedInPix(1)), ...
                    %                         round(TimeForMotion .* Exp.PTB.SpeedInPix(1)) + Exp.Current.PhaseShift]
                else
                    gratingDisp = [round(TimeToStop .* Exp.PTB.SpeedInPix(1)), ...
                        round(TimeToStop .*Exp.PTB.SpeedInPix(1)) + Exp.Current.PhaseShift];
                end
                
                if strcmp(Exp.Type, 'TopDown')
                    % Compute fixation dot displacement based on current time:
                    switch Exp.Current.Phase
                        case 'TEST'
                            switch Exp.Current.LJdifficulty
                                case 'H'
                                    dotDisp(cnt,:) = fGenLissajouT(GetSecs, Exp.Visual.Lissajou.amp, ...
                                        Exp.Visual.Lissajou.fv, Exp.Visual.Lissajou.fh, Exp.Visual.Lissajou.phase);
                                case 'E'
                                    dotDisp(cnt,:) = fGenLissajouT(GetSecs, Exp.Visual.Lissajou.amp, ...
                                        Exp.Visual.Lissajou.fv / 2, Exp.Visual.Lissajou.fh / 2, Exp.Visual.Lissajou.phase);
                            end
                        case 'LEARN'
                            dotDisp(cnt,:) = fGenLissajouT(GetSecs, Exp.Visual.Lissajou.amp, ...
                                Exp.Visual.Lissajou.fv, Exp.Visual.Lissajou.fh, Exp.Visual.Lissajou.phase);
                    end
                else
                    dotDisp(cnt,:) = fGenLissajouT(GetSecs, Exp.Visual.Lissajou.amp, ...
                        Exp.Visual.Lissajou.fv, Exp.Visual.Lissajou.fh, Exp.Visual.Lissajou.phase);
                end
                % Grating 1:
                g1_cst(1) = Exp.PTB.w/2-(Exp.Visual.Grating(1).dutycycle*1/Exp.Visual.Grating(1).freq/2) - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * cosd(Loop_Angle(1));
                g1_cst(2) = Exp.PTB.w/2+(Exp.Visual.Grating(1).dutycycle*1/Exp.Visual.Grating(1).freq/2) - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * cosd(Loop_Angle(1));
                g1_cst(3) = 0 - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * sind(Loop_Angle(1));
                g1_cst(4) = Exp.PTB.h - (Exp.Visual.Grating(1).speed * gratingDisp(1)) * sind(Loop_Angle(1));
                dstRects_g1(1,:) = [g1_cst(1) + (-5).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-5).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-5).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-5).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(2,:) = [g1_cst(1) + (-4).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-4).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-4).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-4).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(3,:) = [g1_cst(1) + (-3).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-3).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-3).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-3).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(4,:) = [g1_cst(1) + (-2).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-2).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-2).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-2).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(5,:) = [g1_cst(1) + (-1).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + (-1).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + (-1).*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + (-1).*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(6,:) = [g1_cst(1) + 0.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 0.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 0.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 0.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(7,:) = [g1_cst(1) + 1.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 1.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 1.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 1.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(8,:) = [g1_cst(1) + 2.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 2.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 2.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 2.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(9,:) = [g1_cst(1) + 3.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 3.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 3.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 3.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                dstRects_g1(10,:) = [g1_cst(1) + 4.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(3) + 4.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1)), g1_cst(2) + 4.*(1/Exp.Visual.Grating(1).freq) * cosd(Loop_Angle(1)), g1_cst(4) + 4.*(1/Exp.Visual.Grating(1).freq) * sind(Loop_Angle(1))];
                
                % Grating 2:
                g2_cst(1) = Exp.PTB.w/2-(Exp.Visual.Grating(2).dutycycle*1/Exp.Visual.Grating(2).freq/2) - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * cosd(Loop_Angle(2));
                g2_cst(2) = Exp.PTB.w/2+(Exp.Visual.Grating(2).dutycycle*1/Exp.Visual.Grating(2).freq/2) - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * cosd(Loop_Angle(2));
                g2_cst(3) = 0 - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * sind(Loop_Angle(2));
                g2_cst(4) = Exp.PTB.h - (Exp.Visual.Grating(2).speed * gratingDisp(2)) * sind(Loop_Angle(2));
                
                dstRects_g2(1,:) = [g2_cst(1) + (-5).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-5).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-5).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-5).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(2,:) = [g2_cst(1) + (-4).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-4).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-4).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-4).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(3,:) = [g2_cst(1) + (-3).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-3).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-3).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-3).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(4,:) = [g2_cst(1) + (-2).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-2).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-2).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-2).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(5,:) = [g2_cst(1) + (-1).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + (-1).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + (-1).*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + (-1).*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(6,:) = [g2_cst(1) + 0.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 0.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 0.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 0.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(7,:) = [g2_cst(1) + 1.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 1.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 1.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 1.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(8,:) = [g2_cst(1) + 2.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 2.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 2.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 2.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(9,:) = [g2_cst(1) + 3.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 3.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 3.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 3.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                dstRects_g2(10,:) = [g2_cst(1) + 4.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(3) + 4.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2)), g2_cst(2) + 4.*(1/Exp.Visual.Grating(2).freq) * cosd(Loop_Angle(2)), g2_cst(4) + 4.*(1/Exp.Visual.Grating(2).freq) * sind(Loop_Angle(2))];
                
                
                % Draw the perceived background
                Screen('Blendfunction', win, GL_ONE, GL_ZERO);
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
                    Screen('FillRect', win, Loop_BackGround .* ones(1,3), Exp.PTB.winRect);
                else
                    Screen('FillRect', win, Exp.Current.BackGround .* ones(1,3), Exp.PTB.winRect);
                end
                Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);
                
                % Draw first grating
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(1,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(2,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(3,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(4,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(5,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(6,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(7,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(8,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(9,:), Loop_Angle(1), [], Loop_Alpha(1));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar1_tex, [], dstRects_g1(10,:), Loop_Angle(1), [], Loop_Alpha(1));
                
                % Draw second grating
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(1,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(2,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(3,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(4,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(5,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(6,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(7,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(8,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(9,:), Loop_Angle(2), [], Loop_Alpha(2));
                Screen('DrawTexture', win, Exp.Stimulus.grat_bar2_tex, [], dstRects_g2(10,:), Loop_Angle(2), [], Loop_Alpha(2));
                
                % Draw aperture
                Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTexture', win, Exp.Stimulus.aperturetex, [], Exp.PTB.winRect);
                
                % Draw normal oval:
                Screen('FillOval', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol 255], Exp.Stimulus.ovRect);
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3 && not(strcmp(Exp.Current.Condition, 'NoRDK'))
                    Screen('Blendfunction', win, GL_ONE, GL_ZERO);
                    Screen('DrawDots', win, [Exp.Current.Particles.pixpos.x(cnt,Exp.Current.Particles.goodDots(cnt,:)); Exp.Current.Particles.pixpos.y(cnt,Exp.Current.Particles.goodDots(cnt,:))], ...
                        Exp.Visual.Common.dotSize, ...
                        [Exp.Visual.Common.dotcol(1), Exp.Visual.Common.dotcol(2), Exp.Visual.Common.dotcol(3)],...
                        [], 2);
                    Screen('Blendfunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                elseif strcmp(Exp.Current.Condition, 'NoRDK')
                    Screen('DrawDots', win, [Exp.PTB.w/2 + dotDisp(cnt,1), Exp.PTB.h/2 + dotDisp(cnt,2)], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
                else
                    Screen('DrawDots', win, [Exp.PTB.w/2 + dotDisp(cnt,1), Exp.PTB.h/2 + dotDisp(cnt,2)], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
                end
                
                % Draw response oval
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
                    Screen('FrameOval', win, Exp.Visual.Common.MouseRespOvalCol - .05, Exp.Stimulus.dst2Rect, 40);
                else
                    Screen('FrameOval', win, Exp.Visual.Common.MouseRespOvalCol, Exp.Stimulus.dst2Rect, 40);
                end
                
                %% Mouse
                % Draw mouse position
                if Exp.Flags.MOUSE
                    if Exp.Flags.DUMMY % Dummy means the computer is doing the mouse task
                        dummy_bad = 0;
                        if dummy_bad
                            if cnt > 1
                                mx(cnt) = (mx(cnt-1) + 1.*randn(1,1));
                                my(cnt) = (my(cnt-1) + 1.*randn(1,1));
                            else
                                mx(cnt) = randn(1,1) + Exp.PTB.w/2;
                                my(cnt) = randn(1,1) + Exp.PTB.h/2;
                            end
                        else
                            if trial == 1
                                lag = 10;
                            else
                                lag = 5;
                            end
                            if cnt > lag
                                mx(cnt) = dotDisp(cnt-lag,1) + Exp.PTB.w/2;
                                my(cnt) = dotDisp(cnt-lag,2) + Exp.PTB.h/2;
                            else
                                mx(cnt) = 0;
                                my(cnt) = 0;
                            end
                        end
                        buttons = zeros(1,3);
                        
                    else % Participant is doing the mouse task
                        [mx(cnt), my(cnt), buttons] = GetMouse(win);
                    end
                    MouseTimes(cnt) = GetSecs;
                    mpos(cnt,:) = [mx(cnt), my(cnt)];
                    
                    %% Compute distance
                    if strcmp(Exp.Type, 'TopDown')
                        Inertia(cnt) = norm([mpos(cnt,1)-Exp.PTB.w/2, mpos(cnt,2)-Exp.PTB.h/2] - dotDisp(cnt,:)) ;
                        t_ = GetSecs; % temps actuel
                        t(cnt) = t_; %vecteur temps
                        %                     inertia_ = nanmean(Inertia(t>=t_ - 0));
                        inertia_ = nanmedian(Inertia(t>=t_ - Exp.Parameters.InertiaTimeWindowSize)); % Inertia Temporal Window Size: median is computed over this sliding time lapse
                        
                        if strcmp(Exp.Current.Condition, 'BL') && strcmp(Exp.Current.Phase, 'LEARN') % in BL Learn, the mouse is not used
                            Screen('DrawDots', win, [Exp.PTB.w/2, Exp.PTB.h/2], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                            
                        else
                            if (t_ - t(1) > Exp.Parameters.InertiaTimeWindowSize) % Give a delay for inertia computation at the begining of trial
                                switch Exp.Current.Phase
                                    case 'TEST'
                                        if inertia_ > InertiaReferenceFinal
                                            %                                         Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.9 .4 .4], [], 2);
                                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                                            dev_cnt(cnt) = 1;
                                        else
                                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                                        end
                                    case 'LEARN'
                                        if Exp.Current.TrialInBlock > 1 && strcmp(Exp.Current.Condition, 'LJ')
                                            if inertia_ > InertiaReference
                                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.9 .4 .4], [], 2);
                                            else
                                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, [.4 .9 .4], [], 2);
                                            end
                                        else
                                            Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                                        end
                                end
                                
                            else
                                Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                            end
                        end
                    else
                        Screen('DrawDots', win, [mx(cnt), my(cnt)], Exp.Visual.Common.dotSize *2, Exp.Visual.Common.dotcol, [], 2);
                    end
                    
                    if Exp.Flags.MOUSECLICKON
                        % Check if buttom is pressed!
                        if sum(buttons) ~= 0
                            BUTTON_TIMEOUT_STARTED = 1;
                            [trial_response(1), trial_response(2)] = GetMouse(win);
                            trial_response(3) = GetSecs;
                            TRIAL_ON = 0;
                        end
                    end
                    
                end
                
                %% Finish drawing
                Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawingFinished', win);
                
                %% Keyboard
                if Exp.Flags.KEYPRESSPERCEPT
                    [keyIsDown, secs, keyCode] = KbCheck;
                    if keyCode(escapeKey)
                        fprintf('Experiment stopped because of escape\n');
                        if Exp.Flags.EYETRACK
                            s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                            Eyelink('Message',s);
                        end
                        if Exp.Flags.EEG % interuption trigger
                            
                        end
                        ShowCursor;
                        sca;
                        return
                    end
                    if keyIsDown && keyCode(spaceKey) && not(MOTION) && strcmp(Exp.Type, 'AfterEffect')
                        fprintf('Trial finished\n')
                        TRIAL_ON = 0;
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).SpaceTime = GetSecs;
                    end
                    
                    % Check the keyboard for escape:
                    if Exp.Flags.DUMMY && not(strcmp(Exp.Current.Condition, 'LJ'))
                        if mod(Exp.Parameters.TrialTimeOut, ...
                                round(GetSecs-Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart))
                            if p_cnt > 0
                                p_cnt = p_cnt - 1;
                                switch p_dum
                                    case 1
                                        keyIsDown = 1; secs = GetSecs; keyCode(leftKey) = 1;
                                    case 2
                                        keyIsDown = 1; secs = GetSecs; keyCode(rightKey) = 1;
                                    case 3
                                        keyIsDown = 1; secs = GetSecs; keyCode(upKey) = 1;
                                end
                                
                            else
                                p_cnt = 40;
                                p_dum = randi(3,1);
                                keyCode = zeros(1,256); keyIsDown = 0;
                            end
                        end
                    end
                    
                    if not(isequal(oldkeyCode, keyCode)) %, keyHasBeenPressed == false)
                        current_time = GetSecs;
                        if p
                            Perception(p,4) = current_time;
                        end
                        p = p + 1;
                        Perception(p,2:3) = current_time;
                        if keyCode(escapeKey)
                            fprintf('Experiment stopped because of escape\n');
                            if Exp.Flags.EYETRACK
                                s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                                Eyelink('Message',s);
                            end
                            if Exp.Flags.EEG % interuption trigger
                                
                            end
                            ShowCursor;
                            
                            if Exp.Flags.EYETRACK
                                s = sprintf('END PHASE\n');
                                Eyelink('Message', s);
                                
                                s = sprintf('END ACQUISITION\n');
                                Eyelink('Message',s);
                                
                                WaitSecs(0.1);
                                Eyelink('StopRecording');
                                Eyelink('CloseFile');
                                if Exp.Flags.SAVE
                                    % save el data file
                                    try
                                        fprintf('Receiving data file ''%s''\n', Exp.EyeLink.edfFile );
                                        status=Eyelink('ReceiveFile');
                                        if status > 0
                                            fprintf('ReceiveFile status %d\n', status);
                                        end
                                        if 2==exist(Exp.EyeLink.edfFile, 'file')
                                            fprintf('Data file ''%s'' can be found in ''%s''\n', Exp.EyeLink.edfFile, pwd );
                                        end
                                    catch err
                                        fprintf('Problem receiving data file ''%s''\n', Exp.EyeLink.edfFile );
                                        psychrethrow(err);
                                    end
                                end
                                
                                WaitSecs(0.1);
                                Eyelink('ShutDown');
                                
                            end
                            if Exp.Flags.EEG % end of phase , end of aquisition triggers
                                
                            end
                            
                            if Exp.Flags.SAVE
                                save(dataFileName, 'Exp');
                            end
                            
                            sca;
                            return
                        end
                        WAITINGPERCEPTREVERSAL = 0;
                        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition,'Dynamic')
                            Exp.Current.NextExoPerceptReversal(end) = [];
                        end
                        
                        if strcmp(Exp.Type, 'AfterEffect')
                            Perception(p, 1) = keyCode([leftKey, rightKey, upKey, downKey]) * [1; 10; 100; 1000];
                        else
                            % RONALD
                            % keyCode([ ]) yields a logical array
                            % example if rightKey is pressed but no other key
                            % keyCode([leftKey, rightKey, upKey]) = [0 1 0]
                            % inner product with [1; 10; 100] gives desired result
                            Perception(p, 1) = keyCode([leftKey, rightKey, upKey]) * [1; 10; 100];
                        end
                        
                        if Exp.Flags.EYETRACK
                            % sending the key was pressed by the user (left=1, down=2 or right=3)
                            s = sprintf('BUTTON : %s\n',num2str(Perception(p,1)));
                            Eyelink('Message',s);
                        end
                        if Exp.Flags.EEG % button pressed trigger
                            
                        end
                        
                        if strcmp(Exp.Type, 'AfterEffect')
                            if ismember(Perception(p, 1), [1, 10, 100, 1000]), % check if pure state
                                PureStates(end+1, :) = [Perception(p, 1) GetSecs];
                            end
                        else
                            % RONALD
                            % need to export stable perception times
                            if ismember(Perception(p, 1), [1, 10, 100]), % check if pure state
                                PureStates(end+1, :) = [Perception(p, 1) GetSecs];
                            end
                        end
                    end
                    oldkeyCode = keyCode;
                    
                else
                    if keyIsDown && keyCode(escapeKey)
                        fprintf('Experiment stopped because of escape\n');
                        if Exp.Flags.EYETRACK
                            s = sprintf('INTERRUPTED DURING EXPERIMENTAL PHASE');
                            Eyelink('Message',s);
                        end
                        if Exp.Flags.EEG
                            
                        end
                        ShowCursor;
                        
                        if Exp.Flags.EYETRACK
                            s = sprintf('END PHASE\n');
                            Eyelink('Message', s);
                            
                            s = sprintf('END ACQUISITION\n');
                            Eyelink('Message',s);
                            
                            WaitSecs(0.1);
                            Eyelink('StopRecording');
                            Eyelink('CloseFile');
                            if Exp.Flags.SAVE
                                % save el data file
                                try
                                    fprintf('Receiving data file ''%s''\n', Exp.EyeLink.edfFile );
                                    status=Eyelink('ReceiveFile');
                                    if status > 0
                                        fprintf('ReceiveFile status %d\n', status);
                                    end
                                    if 2==exist(Exp.EyeLink.edfFile, 'file')
                                        fprintf('Data file ''%s'' can be found in ''%s''\n', Exp.EyeLink.edfFile, pwd );
                                    end
                                catch err
                                    fprintf('Problem receiving data file ''%s''\n', Exp.EyeLink.edfFile );
                                    psychrethrow(err);
                                end
                            end
                            
                            WaitSecs(0.1);
                            Eyelink('ShutDown');
                            
                        end
                        if Exp.Flags.EEG % end phase, end aquisition trigger
                            
                        end
                        
                        if Exp.Flags.SAVE
                            save(dataFileName, 'Exp');
                        end
                        
                        sca;
                        return
                    end
                end
                
                %% Time out
                if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition, 'Short')
                    % Check if keypress is pressed for short trials
                    if p >= 2
                        BUTTON_TIMEOUT_STARTED = 1;
                        TRIAL_ON = 0;
                    end
                    
                end
                if strcmp(Exp.Type, 'AfterEffect') && strcmp(Exp.Current.Phase, 'LEARN') && not(Exp.Pilot==2)
                    % Check if keypress is pressed for short trials
                    if p > Exp.Parameters.ReversalThres+1
                        BUTTON_TIMEOUT_STARTED = 1;
                        TRIAL_ON = 0;
                    end
                end
                
                % Count down one frame for trial time out
                count_down = count_down - 1;
                
                % Check if time is out
                if strcmp(Exp.Type, 'AfterEffect') && or(strcmp(Exp.Current.Phase, 'TEST'),Exp.Pilot==2)
                    if count_down < 0 && WAITINGTOFREEZE
                        count_down = ceil(Exp.Parameters.ExtraTimeOut * (1/Exp.PTB.ifi));
                        % freeze all motor functions
                        MOTION = 0; WAITINGTOFREEZE = 0;
                        TimeToStop = mod(GetSecs - Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimStart, ...
                            (Exp.Visual.Common.apSize) / Exp.PTB.SpeedInPix(1)); %GetSecs;
                    end
                end
                if count_down < 0
                    if keyHasBeenPressed
                        Perception(p,4) = GetSecs;
                    end
                    fprintf('Trial finished\n')
                    TRIAL_ON = 0;
                    if BUTTON_TIMEOUT_STARTED == 0
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).TimeOut = 1;
                    else
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).TimeOut = 0;
                    end
                end
                
                
                %% DONE: Let's flip
                % Flip 'waitframes' monitor refresh intervals after last redraw.
                vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * Exp.PTB.ifi);
                if Exp.Flags.EYETRACK
                    s = sprintf('FLIP FRAME %s\n',num2str(cnt));
                    Eyelink('Message',s);
                end
                if Exp.Flags.EEG % Flip frame trigger
                    putvalue(DIO,32); % Data Acquisition Toolbox
                end
                
                % Next loop iteration...
                Looptimes(cnt) = GetSecs - loopst;
                cnt = cnt + 1;
                
            end
            
            if strcmp(Exp.Type, 'TopDown')
                % RONALD
                % gathering information about the duration of second percept
                % until one-to-last percept and the number of percepts
                % - the first row is a dummy row with the starting time of the trial
                % - the second row is the first percept
                % - the last row is an ongoing percept
                % not counting the first and last percept implies taking 3rd to one-to-last row
                % - number of percepts: length(PureStates) - 3
                % - time: PureStates(end, 2) -PureStates(3, 2)
                perceptDuration(trial, :) = [PureStates(end, 2) - PureStates(3, 2), length(PureStates) - 3];
                
                Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                DrawFormattedText(win, sprintf('Your mean reversal speed for this trial is %.2f', perceptDuration(trial, 2) / perceptDuration(trial, 1)), ...
                    'center','center',Exp.Visual.Common.texcol);
                vbl = Screen('Flip', win);
                WaitSecs(1);
            end
            if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && not(strcmp(Exp.Current.Condition, 'Short'))
                Durations_temp = Perception;
                Durations_temp(end,end) = GetSecs;
                Durations = [Durations; Durations_temp(:,4) - Durations_temp(:,3)];
                paramhat = lognfit(Durations(not(isnan(Durations))));
            end
            
            %% Save data
            Perception(p+1:end,:) = [];
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).StimFinish = GetSecs;
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Response = trial_response;
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData = [mx(not(isnan(mx))), my(not(isnan(my))), MouseTimes(not(isnan(MouseTimes)))];
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).LoopTimes = Looptimes(not(isnan(Looptimes)));
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Perception = Perception;
            if strcmp(Exp.Type, 'TopDown')
                Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).PerformanceDeviation = dev_cnt;
                Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).LissajouDot = [dotDisp(not(isnan(dotDisp(:,1))),1), dotDisp(not(isnan(dotDisp(:,2))),2)];
            end
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).LoopAlphas = [LoopAlphas(not(isnan(LoopAlphas(:,1))),1), LoopAlphas(not(isnan(LoopAlphas(:,2))),2)];
            if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2 && strcmp(Exp.Current.Condition, 'Dynamic')
                Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).LoopBackGround = LoopBackGround(not(isnan(LoopBackGround)));
            end
            if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3 && strcmp(Exp.Current.Condition, 'Estimation')
                if Exp.Flags.MOUSE
                    switch Exp.Current.BiasedPercept
                        case 1
                            Ref = [linspace(Exp.Parameters.DotLimit, -Exp.Parameters.DotLimit, size(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData,1)); ...
                                linspace(-Exp.Parameters.DotLimit, Exp.Parameters.DotLimit, size(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData,1))];
                        case 10
                            Ref = [linspace(-Exp.Parameters.DotLimit, Exp.Parameters.DotLimit, size(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData,1)); ...
                                linspace(-Exp.Parameters.DotLimit, Exp.Parameters.DotLimit, size(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData,1))];
                        case 100
                            Ref = [linspace(0, 0, size(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData,1)); ...
                                linspace(-Exp.Parameters.DotLimit, Exp.Parameters.DotLimit, size(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData,1))];
                    end
                    Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Similarity = fmaxcorrangle(Ref', Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).MouseData(:,1:2));
                    if isnan(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Similarity)
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Similarity = [0; 0];
                    end
                end
            end
            
            
            
            %% LJ Learning process
            if strcmp(Exp.Type, 'TopDown')
                if  strcmp(Exp.Current.Condition, 'LJ') && strcmp(Exp.Current.Phase, 'LEARN')
                    Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Inertia = Inertia(not(isnan(Inertia)));
                    
                    if trial == 1
                        trial_success = 0;
                        temp = sort(Inertia(not(isnan(Inertia))));
                        InertiaReference = temp(round(Exp.Parameters.LearnLJthres * length(Inertia)));
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).InertiaReference = InertiaReference;
                        
                    else
                        criterion = nanmedian(Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Inertia(round(.5/Exp.PTB.ifi) : end)); % approximately ignore first 500ms
                        if criterion > InertiaReference
                            Exp.Current.FeedbackText = 'Echec\n\n';
                            trial_success = 0;
                        else
                            Exp.Current.FeedbackText = 'Succ?s\n\n';
                            trial_success = trial_success + 1;
                        end
                        
                        % Draw the background
                        Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                        DrawFormattedText(win, Exp.Current.FeedbackText,'center','center',Exp.Visual.Common.texcol);
                        vbl = Screen('Flip', win);
                        if Exp.Flags.EYETRACK
                            s = sprintf('FLIP TRIAL JUDGEMENT MSG\n');
                            Eyelink('Message',s);
                        end
                        WaitSecs(1);
                    end
                    
                    if (trial_success < Exp.Parameters.LearnLJsuccess) && (trial == NbTrials)
                        NbTrials = NbTrials + 1;
                    end
                    
                end
                if strcmp(Exp.Current.Phase, 'TEST') && sum(dev_cnt)/length(dev_cnt) > Exp.Parameters.TestLJthres
                    Exp.Current.FeedbackText = 'Attention\n D?viation de la performance du suivi du point sur cette derni?re s?quence!\n\n';
                    Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
                    DrawFormattedText(win, Exp.Current.FeedbackText,'center','center',Exp.Visual.Common.texcol);
                    vbl = Screen('Flip', win);
                    if Exp.Flags.EYETRACK
                        s = sprintf('FLIP TRIAL JUDGEMENT MSG\n');
                        Eyelink('Message',s);
                    end
                    WaitSecs(1);
                end
            end
            
            %% Finish block?
            if trial == NbTrials
                if strcmp(Exp.Type, 'TopDown')
                    if  strcmp(Exp.Current.Condition, 'LJ') && strcmp(Exp.Current.Phase, 'LEARN') % Let's take the final training inertia as a new reference
                        temp = sort(Inertia(not(isnan(Inertia))));
                        InertiaReferenceFinal = temp(round((1 - Exp.Parameters.LearnLJthres) * length(Inertia)));
                        Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).InertiaReference = InertiaReferenceFinal;
                    end
                end
                
                BLOCK_ON = 0;
            end
            
            Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).TrialInfo = Exp.Current;
        end
        
        if strcmp(Exp.Type, 'TopDown')
            % RONALD
            % report mean percept reversal speed for the block
            WaitSecs(.5)
            meanRevSpeed = sum(perceptDuration(:, 2)) / sum(perceptDuration(:, 1));
            Screen('FillRect', win, [Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol, Exp.Visual.Common.bckcol], Exp.PTB.winRect);
            DrawFormattedText(win, sprintf('Your mean reversal speed for this block is %.2f', meanRevSpeed), ...
                'center','center',Exp.Visual.Common.texcol);
            vbl = Screen('Flip', win);
            WaitSecs(1)
        end
        
        if Exp.Flags.SAVEONTHEGO && Exp.Flags.SAVE
            save(dataFileName, 'Exp');
        end
        
    end
end

%% Experiment is finishing: let's save and close things
% Last flip to take end timestamp and for stimulus offset:
vbl = Screen('Flip', win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME LAST TIMESTAMP\n');
    Eyelink('Message',s);
end
if Exp.Flags.EEG % last timestamp trigger
    
end
DrawFormattedText(win, 'Fin\n', 'center', 'center', 0.75)
vbl = Screen('Flip',win);
if Exp.Flags.EYETRACK
    s = sprintf('FLIP FRAME END\n');
    Eyelink('Message',s);
end
if Exp.Flags.EEG % flip frame end trigger
    
end
WaitSecs(1);



if Exp.Flags.EYETRACK
    s = sprintf('END PHASE\n');
    Eyelink('Message', s);
    
    s = sprintf('END ACQUISITION\n');
    Eyelink('Message',s);
    
    WaitSecs(0.1);
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    if Exp.Flags.SAVE
        % save el data file
        try
            fprintf('Receiving data file ''%s''\n', Exp.EyeLink.edfFile );
            status=Eyelink('ReceiveFile');
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist(Exp.EyeLink.edfFile, 'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n', Exp.EyeLink.edfFile, pwd );
            end
        catch err
            fprintf('Problem receiving data file ''%s''\n', Exp.EyeLink.edfFile );
            psychrethrow(err);
        end
    end
    
    WaitSecs(0.1);
    Eyelink('ShutDown');
    
end
if Exp.Flags.EEG % final trigger
    
end


if Exp.Flags.SAVE
    save(dataFileName, 'Exp');
end

% Close onscreen window, release all ressources:
sca;
ShowCursor;