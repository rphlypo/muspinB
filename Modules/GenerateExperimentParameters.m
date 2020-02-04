% Generate experiment parameters
function [Exp] = GenerateExperimentParameters(Exp)

Exp.Parameters = struct();

% Number of phases:
if Exp.Flags.LEARNON
    Exp.Parameters.NumberOfPhases = 2;
else
    Exp.Parameters.NumberOfPhases = 1;
end

if strcmp(Exp.Type, 'GazeEEG')
    % Conditions
    Exp.Parameters.Conditions = {'Amb-Kp', 'nAmb-Kp', 'Amb-nKp', 'nAmb-nKp'};
    Exp.Parameters.LearnConditions = {'Amb-Kp', 'nAmb-Kp', 'Amb-nKp', 'nAmb-nKp'};
    % Number of trials per conditions
    Exp.Parameters.NumberOfTrialsPerCond = 10;
    % Length of blocks in trials
    Exp.Parameters.LengthOfBlocks = Exp.Parameters.NumberOfTrialsPerCond; %10;
    Exp.Parameters.NumberOfBlocks = length(Exp.Parameters.Conditions); %4; 
    Exp.Parameters.LengthOfBlocksLearn = 4;
    % Timeout of trials in seconds:
    Exp.Parameters.TrialTimeOut = 40;
    % Reversal needed to end trial:
    Exp.Parameters.ReversalThres = 40;
    % Gaussian sampling parameters for alpha selection:
    Exp.Parameters.AlphaSampling = [.5, .05];
    Exp.Parameters.AlphaPercepts = ...
        [1, .95, .05; ...
        10, .05, .95; ...
        100, .95, .95];
    
end
if strcmp(Exp.Type, 'TopDown')
    % Possible Conditions
    Exp.Parameters.Conditions = {'BL', 'HO', 'SW'};
    Exp.Parameters.LearnConditions = {'BL', 'LJ', 'HO', 'SW'};
    
    % Number of trials per conditions
    Exp.Parameters.NumberOfTrialsPerCond = 30;
    % Exp.Parameters.NumberOfTrialsTotal = Exp.Parameters.NumberOfTrialsPerCond * length(Exp.Parameters.Conditions);
    
    % Length of blocks in trials:
    Exp.Parameters.LengthOfBlocks = 16; % doit ?tre pair
    Exp.Parameters.NumberOfBlocks = 3; % in test
    Exp.Parameters.LengthOfBlocksLearn = 3;
    
    % Timeout of trials in seconds:
    Exp.Parameters.TrialTimeOut = 180; % ? changer, valeur de debuggage -> 180 secondes
    % Exp.Parameters.TrialTimeOut = @(mean, jit) mean + (rand-1/2)*2*jit; % mean + (rand-1/2)*2*jitter
    
    % Reversal needed to end trial:
    % Exp.Parameters.ReversalThres = 1;
    
    % Possible Orientations:
    % Exp.Parameters.BaseLineOrientations = nan(1,9);
    
    % Beta Distribution parameters:
    % Exp.Parameters.BetaParam = [.25 .25];
    Exp.Parameters.BetaParam = [1 1];
    
    % Inertia parameters:
    Exp.Parameters.InertiaTimeWindowSize = .5; % in seconds
    Exp.Parameters.LearnLJthres = .25; % seuil en pourcentil ? d?passer pour valider un essai LJ
    Exp.Parameters.LearnLJsuccess = 5; % nombre d'essai ? r?ussir cons?cutivement
    Exp.Parameters.TestLJthres = .25;
end

if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
    % Possible Conditions
    Exp.Parameters.Conditions = {'Amb'};
    Exp.Parameters.LearnConditions = Exp.Parameters.Conditions;
    % Number of trials per conditions
    Exp.Parameters.NumberOfTrialsPerCond = 500;
    
    % Length of blocks in trials:
    Exp.Parameters.LengthOfBlocks = 50; % doit ?tre pair
    Exp.Parameters.NumberOfBlocks = 10; % in test
    Exp.Parameters.LengthOfBlocksLearn = 10;
    
    % Timeout of trials in seconds:
    Exp.Parameters.TrialTimeOut = @(mean, jit) mean + (rand-1/2)*2*jit; % mean + (rand-1/2)*2*jitter
    
    % Reversal needed to end trial:
    Exp.Parameters.ReversalThres = 1;
    
    % Possible Orientations:
    Exp.Parameters.BaseLineOrientations = nan(1,9);
    
    % Beta Distribution parameters:
    Exp.Parameters.BetaParam = [.25 .25];
end

if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
    % Possible Conditions
    Exp.Parameters.Conditions = {'Short',  'Dynamic', 'Long'};
    Exp.Parameters.LearnConditions = Exp.Parameters.Conditions;
    % Number of trials per conditions (table/vector)
    Exp.Parameters.NumberOfTrialsPerCond = [200, 10, 3]; %[200, 10, 5]; %
    % Length of blocks in trials:
    Exp.Parameters.LengthOfBlocks = Exp.Parameters.NumberOfTrialsPerCond;
    Exp.Parameters.NumberOfBlocks = size(Exp.Parameters.NumberOfTrialsPerCond, 2); % in test
    Exp.Parameters.LengthOfBlocksLearn = 1;
    
    % Timeout of trials in seconds: (long and dynamics)
    Exp.Parameters.TrialTimeOut = 120; % 120 sec
    % Reversal needed to end trial: (short)
    Exp.Parameters.ReversalThres = 1;
    % Parameters of the Dynamic condition transitions :
    Exp.Parameters.ManipCntMax = 3;%15;
    %     Exp.Parameters.DynamicStep = .1;
    Exp.Parameters.AlphaPercepts = ...
        [1, .95, .05; ...
        10, .05, .95; ...
        100, .95, .95];
    % Gaussian sampling parameters for alpha selection:
    Exp.Parameters.AlphaSampling = [.5, .05];
end
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
    % Possible Conditions
    switch Exp.Flags.PREPILOT
        case 1
            Exp.Parameters.Conditions = {'NoRDK', '00_000',...
                '01_000','01_060','01_090','01_120','01_180','01_240','01_270','01_300',...
                '02_000','02_060','02_090','02_120','02_180','02_240','02_270','02_300'};
            % Number of trials per conditions (table/vector)
            Exp.Parameters.NumberOfTrialsPerCond = 1;
        case 2
            Exp.Parameters.Conditions = {'NoRDK', '00_000',...
                '05_000','05_060','05_090','05_120','05_180','05_240','05_270','05_300'};
            % Number of trials per conditions (table/vector)
            Exp.Parameters.NumberOfTrialsPerCond = 1;
        case 3
            Exp.Parameters.Conditions = {'NoRDK', '00_000',...
                '05_000','05_090','05_180','05_270',...
                '09_000','09_090','09_180','09_270'};
            % Number of trials per conditions (table/vector)
            Exp.Parameters.NumberOfTrialsPerCond = 3;
    end
    Exp.Parameters.LearnConditions = Exp.Parameters.Conditions;
    
    % Length of blocks in trials:
    Exp.Parameters.LengthOfBlocks = length(Exp.Parameters.Conditions); %Exp.Parameters.NumberOfTrialsPerCond;
    Exp.Parameters.NumberOfBlocks = Exp.Parameters.NumberOfTrialsPerCond;%size(Exp.Parameters.NumberOfTrialsPerCond, 2); % in test
    Exp.Parameters.LengthOfBlocksLearn = 1;
    
    % Timeout of trials in seconds:
    Exp.Parameters.TrialTimeOut = 40; % sec
    % RDK parameters:
    Exp.Parameters.nDots = 100;
    %     Exp.Parameters.CohPerc = [0, 0.1, 0.2]; % percentage of dots going coherent
    Exp.Parameters.CoherenceSpeed = 1.5; %.05;
    %     Exp.Parameters.CohDir = [-120 -90 -60 0 60 90 120 180]; % direction of dots
    %     Exp.Parameters.ManipTime = 1.000; % seconds
    Exp.Parameters.DotLimit = [2, 2]; % in degrees %30; % up to how far the dots can go
    Exp.Parameters.LognRnd = [1, 1];
    %     Exp.Parameters.Method = 'Saccade' ; %'Pursuit'; % 'Saccade'
    %     Exp.Parameters.StepProcedureStep = .01; % size of step to increase/decrease CoherencePercentage
    %     Exp.Parameters.StepProcedureTrialNbStop = 10;
    Exp.Parameters.SimilarityThres = .8;
end
if strcmp(Exp.Type, 'AfterEffect')
    % Possible Conditions
    switch Exp.Pilot
        case 0
            Exp.Parameters.Conditions = {'Ambiguous', 'Right', 'Left', 'Coherent'};
            Exp.Parameters.LearnConditions = {'Ambiguous'};
            % Number of trials per conditions
            Exp.Parameters.NumberOfTrialsPerCond = 5;
            % Length of blocks in trials:
            Exp.Parameters.LengthOfBlocks = 15; % doit ?tre pair
            Exp.Parameters.NumberOfBlocks = 4; % in test
            
            Exp.Parameters.LengthOfBlocksLearn = 6;
            % Possible Orientations:
            Exp.Parameters.BaseLineOrientations = [0, 90, 180, 270];
            % Reversal needed to end trial:
            Exp.Parameters.ReversalThres = 2;
            % Timeout of trials in seconds:
            Exp.Parameters.TrialTimeOut = 20;
            Exp.Parameters.ExtraTimeOut = 5;
        case 1
            Exp.Parameters.Conditions = {'Right', 'Left', 'Coherent'};
            Exp.Parameters.LearnConditions = {'Ambiguous'};
            % Number of trials per conditions
            Exp.Parameters.NumberOfTrialsPerCond = 5;
            % Length of blocks in trials:
            Exp.Parameters.LengthOfBlocks = 5;
            Exp.Parameters.NumberOfBlocks = 3;
            
            Exp.Parameters.LengthOfBlocksLearn = 6;
            % Possible Orientations:
            Exp.Parameters.BaseLineOrientations = [0, 90, 180, 270];
            % Reversal needed to end trial:
            Exp.Parameters.ReversalThres = 2;
            % Timeout of trials in seconds:
            Exp.Parameters.TrialTimeOut = 20;
            Exp.Parameters.ExtraTimeOut = 5;
        case 2
            Exp.Parameters.Conditions = {'Ambiguous', 'Coherent', 'Right', 'Left'};
            Exp.Parameters.LearnConditions = {'Coherent', 'Left', 'Right'};
            % Number of trials per conditions
            Exp.Parameters.NumberOfTrialsPerCond = [12 6 3 3];
            % Length of blocks in trials:
            Exp.Parameters.LengthOfBlocks = 6;
            Exp.Parameters.NumberOfBlocks = 4;
            Exp.Parameters.LengthOfBlocksLearn = 3;
            % Possible Orientations:
            Exp.Parameters.BaseLineOrientations = 0;
            % Reversal needed to end trial:
            Exp.Parameters.ReversalThres = 20;
            % Timeout of trials in seconds:
            Exp.Parameters.TrialTimeOut = 20;
            Exp.Parameters.ExtraTimeOut = 15;
    end
end
end