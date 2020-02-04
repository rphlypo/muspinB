% Generate Experiment Structure
function [Exp] = GenerateExperimentStructure(Exp)

Exp.Structure = struct();
% Learn phase
switch Exp.Flags.LEARNON
    case 1
        if strcmp(Exp.Type, 'GazeEEG')
            Exp.Structure.Learn = Exp.Parameters.LearnConditions;
        end
        if strcmp(Exp.Type, 'TopDown')
            %% Exp? TOP DOWN 2
            % 4 blocks de n essais de 4 conditions dans l'ordre
            % Pour LJ; il faut que n essais cons?cutifs soient en dessous d'un
            % seuil
            %         Exp.Structure.Learn = Exp.Parameters.LearnConditions;
            Exp.Structure.Learn = repmat(Exp.Parameters.LearnConditions', 1, Exp.Parameters.LengthOfBlocksLearn);
        end
        
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
            % Order of trials of Learn phase
            [Exp.Structure.Learn.TrialMixValue, Exp.Structure.Learn.TrialOriginalIndex] = ...
                Shuffle(repmat(1:length(Exp.Parameters.Conditions), 1,...
                sqrt(Exp.Parameters.LearnLength)));
            % Order of Orientations
            [Exp.Structure.Learn.OrientationsMixValue, Exp.Structure.Learn.OrientationsOriginalIndex] = ...
                Shuffle(repmat(1:length(Exp.Parameters.BaseLineOrientations), ...
                1, length(Exp.Structure.Learn.TrialMixValue)/length(Exp.Parameters.BaseLineOrientations)),1);
            if length(Exp.Structure.Learn.TrialMixValue) == length(Exp.Structure.Learn.OrientationsMixValue)
                % Length of Learn phase in trials
                Exp.Structure.Learn.NbTrials = length(Exp.Structure.Learn.TrialMixValue);
            else
                fprintf('ERROR: Cannot decide number of LEARN trials\n')
                return;
            end
        end
        
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
            % make 1 of each trial types
            Exp.Structure.Learn = Exp.Parameters.LearnConditions;
        end
        
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
            % make 1 of each trial types
            if Exp.Flags.PREPILOT
                Exp.Structure.Learn = repmat(Exp.Parameters.LearnConditions,1,Exp.Parameters.LengthOfBlocksLearn);
            else
                Exp.Structure.Learn = Exp.Parameters.LearnConditions;
            end
        end
        if strcmp(Exp.Type, 'AfterEffect')
            switch Exp.Pilot
                case 1
            % Order of conditions
            %             [Exp.Structure.Learn.TrialMixValue, Exp.Structure.Learn.TrialOriginalIndex] = ...
            %                 Shuffle(1:length(Exp.Parameters.Conditions));
            Exp.Structure.Learn.TrialMixValue = ones(1, Exp.Parameters.LengthOfBlocksLearn);
            % Order of Orientations
            %             [Exp.Structure.Learn.OrientationsMixValue, Exp.Structure.Learn.OrientationsOriginalIndex] = ...
            %                 Shuffle(Exp.Parameters.BaseLineOrientations);
            Exp.Structure.Learn.OrientationsMixValue = ...
                Exp.Parameters.BaseLineOrientations(randi(length(Exp.Parameters.BaseLineOrientations), 1, Exp.Parameters.LengthOfBlocksLearn));
                case 2
                    Exp.Structure.Learn.TrialMixValue = [1 2 3];
                    Exp.Structure.Learn.OrientationsMixValue = [0 0 0];
            end
        end
    case 0
        % mostly for debugging Test phase
end

%% Test phase
% Order of trials
if strcmp(Exp.Type, 'GazeEEG')
    Exp.Structure.Test.TrialOriginalIndex = [ones(Exp.Parameters.LengthOfBlocks,1); 2.*ones(Exp.Parameters.LengthOfBlocks,1); 3.*ones(Exp.Parameters.LengthOfBlocks,1)];
    Exp.Structure.Test.TrialMixValue = reshape(Shuffle(Exp.Structure.Test.TrialOriginalIndex), ...
        Exp.Parameters.NumberOfBlocks, Exp.Parameters.LengthOfBlocks);
end

if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
    [Exp.Structure.Test.TrialMixValue, Exp.Structure.Test.TrialOriginalIndex] = ...
        Shuffle(reshape(repmat(1:length(Exp.Parameters.Conditions), ...
        Exp.Parameters.LengthOfBlocks,1),Exp.Parameters.NumberOfTrialsTotal,1));
    % Order of Orientations
    [Exp.Structure.Test.OrientationsMixValue, Exp.Structure.Test.OrientationsOriginalIndex] = ...
        Shuffle(repmat(1:length(Exp.Parameters.BaseLineOrientations), ...
        1, length(Exp.Structure.Test.TrialMixValue)/length(Exp.Parameters.BaseLineOrientations)),1);
end

if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
    % 3 phases to code :
    % 1. short trials, first percept
    Exp.Structure.Test = repmat(Exp.Parameters.Conditions(1), 1, Exp.Parameters.NumberOfTrialsPerCond(1));
    % 2. long trials, model adjustment
    Exp.Structure.Test(2,1:Exp.Parameters.NumberOfTrialsPerCond(2)) = repmat(Exp.Parameters.Conditions(2), 1, Exp.Parameters.NumberOfTrialsPerCond(2));
    % 3. testing
    Exp.Structure.Test(3,1:Exp.Parameters.NumberOfTrialsPerCond(3)) = repmat(Exp.Parameters.Conditions(3), 1, Exp.Parameters.NumberOfTrialsPerCond(3));
end
if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
    if Exp.Flags.PREPILOT
        Exp.Structure.Test = repmat(Exp.Parameters.Conditions, Exp.Parameters.NumberOfTrialsPerCond(1), 1);
        for k = 1 : size(Exp.Structure.Test, 1)
            Exp.Structure.Test(k,:) = Shuffle(Exp.Structure.Test(k,:));
        end
        Exp.Structure.Test = transpose(Exp.Structure.Test);
        %         Exp.Structure.Trials = Shuffle(repmat(...
        %             linspace(...
        %             1,length(Exp.Parameters.CohPerc),length(Exp.Parameters.CohPerc)),...
        %             1, length(Exp.Structure.Test)/length(Exp.Parameters.CohPerc)));
    else
        Exp.Structure.Test = repmat(Exp.Parameters.Conditions(1), 1, Exp.Parameters.NumberOfTrialsPerCond(1));
        Exp.Structure.Test(2,1:Exp.Parameters.NumberOfTrialsPerCond(2)) = repmat(Exp.Parameters.Conditions(2), 1, Exp.Parameters.NumberOfTrialsPerCond(2));
        Exp.Structure.Test(3,1:Exp.Parameters.NumberOfTrialsPerCond(3)) = repmat(Exp.Parameters.Conditions(3), 1, Exp.Parameters.NumberOfTrialsPerCond(3));
    end
end

if strcmp(Exp.Type, 'TopDown')
    % structure de TOP DOWN 2:
    switch Exp.Flags.SHUFFLING
        case 'None'
            Exp.Structure.Test = repmat(Exp.Parameters.Conditions', size(Exp.Parameters.Conditions,1), Exp.Parameters.NumberOfTrialsPerCond);
            
        case 'Blocks' % only switch and hold
            temp = Exp.Parameters.Conditions(2:3);
            block_shuffled = [Exp.Parameters.Conditions(1), temp(randperm(2))];
            %         Exp.Structure.Test = repmat(block_shuffled', size(Exp.Parameters.Conditions,1), Exp.Parameters.NumberOfTrialsPerCond);
            Exp.Structure.Test = repmat(block_shuffled', Exp.Parameters.NumberOfBlocks/length(Exp.Parameters.Conditions), Exp.Parameters.LengthOfBlocks);
            
            speeds = [zeros(Exp.Parameters.NumberOfBlocks, Exp.Parameters.LengthOfBlocks/2), ones(Exp.Parameters.NumberOfBlocks, Exp.Parameters.LengthOfBlocks/2)];
            for b = 1 : Exp.Parameters.NumberOfBlocks
                %     Exp.Structure.Test = [Exp.Structure.Test; Exp.Parameters.Conditions(randperm(Exp.Parameters.LengthOfBlocks))];
                Exp.Structure.Speeds(b,:) = speeds(b,randperm(size(speeds,2)));
            end
            
        case 'Trials'
            % 4 blocks de 3 essais de 3 conditions al?atoire
            Exp.Structure.Test = repmat(Exp.Parameters.Conditions, Exp.Parameters.NumberOfBlocks, 1);
            for b = 1 : Exp.Parameters.NumberOfBlocks
                %     Exp.Structure.Test = [Exp.Structure.Test; Exp.Parameters.Conditions(randperm(Exp.Parameters.LengthOfBlocks))];
                Exp.Structure.Test(b,:) = Exp.Structure.Test(b,randperm(size(Exp.Structure.Test,2)));
            end
    end
end
if strcmp(Exp.Type, 'AfterEffect')
    % Order of conditions
    %     [Exp.Structure.Test.TrialMixValue, Exp.Structure.Test.TrialOriginalIndex] = ...
    %         Shuffle(repmat(transpose(1:length(Exp.Parameters.Conditions)), 1,Exp.Parameters.LengthOfBlocks));
    switch Exp.Pilot
        case 0
            if randi(2) == 1
                select = 8;
            else
                select = 7;
            end
            Exp.Structure.Test.TrialOriginalIndex = [ones(30,1); 2.*ones(select,1); 3.*ones(15-select,1); 4.*ones(15,1)];
            Exp.Structure.Test.TrialMixValue = reshape(Shuffle(Exp.Structure.Test.TrialOriginalIndex), ...
                Exp.Parameters.NumberOfBlocks, Exp.Parameters.LengthOfBlocks);
        case 1
            Exp.Structure.Test.TrialOriginalIndex = [ones(Exp.Parameters.LengthOfBlocks,1); 2.*ones(Exp.Parameters.LengthOfBlocks,1); 3.*ones(Exp.Parameters.LengthOfBlocks,1)];
            Exp.Structure.Test.TrialMixValue = reshape(Shuffle(Exp.Structure.Test.TrialOriginalIndex), ...
                Exp.Parameters.NumberOfBlocks, Exp.Parameters.LengthOfBlocks);
        case 2
            Exp.Structure.Test.TrialOriginalIndex = [ones(Exp.Parameters.LengthOfBlocks,1); 2.*ones(Exp.Parameters.LengthOfBlocks,1); 3.*ones(Exp.Parameters.LengthOfBlocks,1); 4.*ones(Exp.Parameters.LengthOfBlocks,1)];
            Exp.Structure.Test.TrialMixValue = reshape(Shuffle(Exp.Structure.Test.TrialOriginalIndex), ...
                Exp.Parameters.NumberOfBlocks, Exp.Parameters.LengthOfBlocks);
    end
    % Order of Orientations
    if Exp.Pilot == 2
        [Exp.Structure.Test.OrientationsMixValue, Exp.Structure.Test.OrientationsOriginalIndex] = ...
            Shuffle(repmat(Exp.Parameters.BaseLineOrientations',Exp.Parameters.NumberOfBlocks,Exp.Parameters.LengthOfBlocks));
    else
        [Exp.Structure.Test.OrientationsMixValue, Exp.Structure.Test.OrientationsOriginalIndex] = ...
            Shuffle(repmat(Exp.Parameters.BaseLineOrientations', 1,Exp.Parameters.LengthOfBlocks));
    end
end
end