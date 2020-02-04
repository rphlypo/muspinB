% Update Current Trial structure

function [Exp] = UpdateExpCurrent(Exp, UpdateFunction, arg)

switch UpdateFunction
    case 'Phase'
        % What phase are we in?
        if Exp.Flags.LEARNON
            switch arg
                case 1
                    Exp.Current.Phase = 'LEARN';
                case 2
                    Exp.Current.Phase = 'TEST';
            end
        else
            Exp.Current.Phase = 'TEST';
        end
        
    case 'Block'
        % What block are we in?
        Exp.Current.Block = arg;
        
        if strcmp(Exp.Current.Phase, 'LEARN')
            if strcmp(Exp.Type, 'AfterEffect')
                Exp.Current.Condition = Exp.Parameters.LearnConditions(Exp.Structure.Learn.TrialMixValue(Exp.Current.Block));
            else
                Exp.Current.Condition = Exp.Structure.Learn{Exp.Current.Block};
            end
        end
        
    case 'Trial'
        % What trial is this?
        
        Exp.Current.TrialInBlock = arg(1);
        if strcmp(Exp.Current.Phase, 'TEST')
            Exp.Current.TrialInTest = arg(2);
        end
        Exp.Current.TrialInExp = arg(3);
        
        %% What has been manipulated?
        % What condition are we in?
        if strcmp(Exp.Type, 'TopDown')
            switch Exp.Current.Phase
                case 'LEARN'
                    if Exp.Current.Block == 2
                        Exp.Current.Condition = Exp.Parameters.LearnConditions{2};
                    else
                        Exp.Current.Condition = Exp.Structure.Learn{Exp.Current.Block, Exp.Current.TrialInBlock};
                    end
                case 'TEST'
                    Exp.Current.Condition = Exp.Structure.Test{Exp.Current.Block, Exp.Current.TrialInBlock};
            end
        elseif strcmp(Exp.Type, 'AfterEffect')
            switch Exp.Current.Phase
                case 'LEARN'
                    Exp.Current.Condition = Exp.Parameters.LearnConditions(Exp.Structure.Learn.TrialMixValue(Exp.Current.TrialInBlock));
                case 'TEST'
                    Exp.Current.Condition = Exp.Parameters.Conditions(Exp.Structure.Test.TrialMixValue(Exp.Current.Block, Exp.Current.TrialInBlock));
            end
        else
            switch Exp.Current.Phase
                case 'LEARN'
                    Exp.Current.Condition = Exp.Structure.Learn{Exp.Current.Block};
                    
                case 'TEST'
                    Exp.Current.Condition = Exp.Structure.Test{Exp.Current.Block, Exp.Current.TrialInBlock};
            end
        end
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
            switch Exp.Current.Phase
                case 'LEARN'
                    Exp.Current.Condition = Exp.Structure.Learn{arg(1)};
                case 'TEST'
                    Exp.Current.Condition = Exp.Structure.Test{arg(1)};
            end
            if strcmp(Exp.Current.Condition, 'NoRDK')
                Exp.Current.CohPerc = 0;
                Exp.Current.CohDir = 0;
            else
                Exp.Current.CohPerc = str2num(Exp.Current.Condition(2))*.1;
                Exp.Current.CohDir = str2num(Exp.Current.Condition(4:end));
            end
        end
        
        % What are the alphas?
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
            Exp.Current.Alphas = [betarnd(Exp.Parameters.BetaParam(1), Exp.Parameters.BetaParam(2)), ...
                betarnd(Exp.Parameters.BetaParam(1), Exp.Parameters.BetaParam(2))]; % exp? bottom up
        end
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
            if strcmp(Exp.Current.Condition,'Long') && strcmp(Exp.Current.Phase, 'TEST') && arg(1) ~= 1
                [Exp.Current.Obs] = ExtractObs(Exp, arg(1));
                [Exp.Current.Alphas(1), Exp.Current.AlphaEq, Exp.Current.AlgoFlag] = ModelEstimation_Alpha2(Exp.Current.Obs, Exp.Parameters.AlphaSampling);
            elseif strcmp(Exp.Current.Condition,'Dynamic')
                switch Exp.Current.Phase
                    case 'TEST'
                        Exp.Current.Alphas(1) = AlphaEqSelect(Exp.Data.TEST(2).Trial(end).TrialInfo.AlphaEq);
                        Exp.Current.AlphasPercept = Exp.Parameters.AlphaPercepts;
                    case 'LEARN'
                        Exp.Current.Alphas(1) = .5; %.5 + .1 .* randn;
                        Exp.Current.Alphas(Exp.Current.Alphas > 1) = 1; Exp.Current.Alphas(Exp.Current.Alphas < 0) = 0;
                        Exp.Current.AlphasPercept = Exp.Parameters.AlphaPercepts;
                        
                end
            else
                Exp.Current.Alphas(1) = rand;
            end
            Exp.Current.Alphas(2) = 1 - Exp.Current.Alphas(1);
        end
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
            switch Exp.EyeLink.PlaidOn
                case '0'
                    Exp.Current.Alphas = [0 , 0];
                case '1'
                    Exp.Current.Alphas = [0.5 , 0.5];
            end
            if Exp.Flags.PREPILOT
                %                 Exp.Current.CohPerc = Exp.Parameters.CohPerc(Exp.Structure.Trials(arg(1))); %.1 + (.3 - .1) * rand;
            else
                switch Exp.Current.Phase
                    case 'TEST'
                        if arg(1) == 1
                            Exp.Current.CohPerc = Exp.Parameters.CohPerc;
                            Exp.Current.StepRegime = 'Up';
                            Exp.Current.StepTrialCnt = 1;
                        else
                            if Exp.Current.StepTrialCnt < Exp.Parameters.StepProcedureTrialNbStop
                                Exp.Current.StepTrialCnt = Exp.Current.StepTrialCnt + 1;
                                % Verify what regime to apply
                                if Exp.Data.TEST(1).Trial(arg(1)-1).Similarity < Exp.Parameters.SimilarityThres(1)
                                    Exp.Current.StepRegime = 'Up';
                                else
                                    Exp.Current.StepRegime = 'Down';
                                end
                                % Apply regime
                                switch Exp.Current.StepRegime
                                    case 'Up'
                                        Exp.Current.CohPerc = Exp.Data.TEST(1).Trial(arg(1)-1).TrialInfo.CohPerc + Exp.Parameters.StepProcedureStep;
                                    case 'Down'
                                        Exp.Current.CohPerc = Exp.Data.TEST(1).Trial(arg(1)-1).TrialInfo.CohPerc - Exp.Parameters.StepProcedureStep;
                                end
                            end
                        end
                    case 'LEARN'
                        Exp.Current.CohPerc = Exp.Parameters.CohPerc;
                end
            end
            
        end
        if strcmp(Exp.Type, 'TopDown')
            Exp.Current.Alphas = [Exp.Visual.Grating(1).globalAlpha, Exp.Visual.Grating(2).globalAlpha]; % exp? top down
        end
        if strcmp(Exp.Type, 'AfterEffect')
            switch Exp.Current.Phase
                case 'LEARN'
                    switch Exp.Current.Condition{1}
                        case 'Ambiguous'
                            Exp.Current.Alphas = [.5, .5];
                        case 'Left'
                            Exp.Current.Alphas = [1, 0];
                        case 'Right'
                            Exp.Current.Alphas = [0, 1];
                        case 'Coherent'
                            Exp.Current.Alphas = [1, 1];
                    end
                case 'TEST'
                    switch Exp.Current.Condition{1}
                        case 'Ambiguous'
                            Exp.Current.Alphas = [.5, .5];
                        case 'Left'
                            Exp.Current.Alphas = [.9, .1];
                        case 'Right'
                            Exp.Current.Alphas = [.1, .9];
                        case 'Coherent'
                            Exp.Current.Alphas = [.9, .9];
                    end
            end
        end
        
        % Adjust luminance and contrast depending on alphas picked:
        
        [Exp.Current.Luminance, Exp.Current.Contrast] = fLuminanceContrast(Exp.Current.Alphas, ...
            Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
        [Exp.Current.BetaLum, Exp.Current.OffsetLum] = fEgalisateur(Exp.Current.Luminance, Exp.Current.Contrast, ...
            Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
        Exp.Current.GratingLum(1) = Exp.Current.BetaLum * Exp.Visual.Grating(1).mean + Exp.Current.OffsetLum;
        Exp.Current.GratingLum(2) = Exp.Current.BetaLum * Exp.Visual.Grating(2).mean + Exp.Current.OffsetLum;
        Exp.Current.BackGround = Exp.Current.BetaLum * Exp.Visual.Common.bckcol2 + Exp.Current.OffsetLum;
        
        % What parameters are we manipulating given the condition we are in?
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
            Exp.Current.BaseLineOrientation = round(0 + (180-0).*rand(1,1)); % exp? bottom up
        else
            Exp.Current.BaseLineOrientation = 0;
        end
        if strcmp(Exp.Type, 'AfterEffect')
            switch Exp.Current.Phase
                case 'LEARN'
                    Exp.Current.BaseLineOrientation = Exp.Structure.Learn.OrientationsMixValue(Exp.Current.TrialInBlock);
                case 'TEST'
                    Exp.Current.BaseLineOrientation = Exp.Structure.Test.OrientationsMixValue(Exp.Current.Block, Exp.Current.TrialInBlock);
            end
        end
        
        % What phase shift? in pixels
        a = 0; b = 50;
        Exp.Current.PhaseShift = a + (b-a).*rand(1,1);
        
        % What are the jitter values? (for timing)
        a = .9; b = 1.3;
        Exp.Current.FixPointJit = a + (b-a).*rand(1,1);
        
        if strcmp(Exp.Type, 'TopDown')
            % What lissajou difficulty?
            switch Exp.Current.Phase
                case 'LEARN'
                    Exp.Current.LJdifficulty = 'H';
                case 'TEST'
                    switch Exp.Structure.Speeds(Exp.Current.Block, Exp.Current.TrialInBlock)
                        case 1
                            Exp.Current.LJdifficulty = 'H';
                        case 0
                            Exp.Current.LJdifficulty = 'E';
                    end
            end
        end
        
        
        % What text to be displayed?
        if strcmp(Exp.Type, 'AfterEffect')
            Exp.Current.Text = ['Phase ' Exp.Current.Phase ' - Bloc ' num2str(Exp.Current.Block) ' - Trial ' num2str(Exp.Current.TrialInExp) '\n\n' Exp.Text.taskMsg];
        end
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 1
        end
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 2
            switch Exp.Current.Condition
                case 'Short'
                    Exp.Current.Text = [Exp.Current.Phase ' - ' Exp.Current.Condition '\n\n'...
                        'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                        'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                        Exp.Text.taskMsg.Short '\n\n'...
                        Exp.Text.readyMsg];
                case 'Long'
                    Exp.Current.Text = [Exp.Current.Phase ' - ' Exp.Current.Condition '\n\n'...
                        'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                        'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                        Exp.Text.taskMsg.Long '\n\n'...
                        Exp.Text.readyMsg];
                case 'Dynamic'
                    Exp.Current.Text = [Exp.Current.Phase ' - ' Exp.Current.Condition '\n\n'...
                        'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                        'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                        Exp.Text.taskMsg.Dynamic '\n\n'...
                        Exp.Text.readyMsg];
            end
        end
        if strcmp(Exp.Type, 'BottomUp') && Exp.Pilot == 3
            Exp.Current.Text = [Exp.Current.Phase '\n\n' ...%' - ' Exp.Current.Condition '\n\n'...
                'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                Exp.Text.taskMsg '\n\n'...
                Exp.Text.readyMsg];
        end
        if strcmp(Exp.Type, 'TopDown')
            switch Exp.Current.Phase
                case 'LEARN'
                    switch Exp.Current.Condition
                        case 'BL'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.BaselineL;
                        case 'SW'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.Switch;
                        case 'HO'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.Hold;
                        case 'LJ'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.LJ;
                    end
                    if strcmp(Exp.Current.Condition, 'LJ')
                        Exp.Current.Text = ['Entra?nement - ' Exp.Current.Condition '\n\n'...
                            'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                            'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                            Exp.Current.taskMsg '\n\n'...
                            Exp.Text.readyMsg];
                    else
                        Exp.Current.Text = ['Entra?nement - ' Exp.Current.Condition '\n\n'...
                            'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                            'Essai : ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Parameters.LengthOfBlocksLearn) '\n\n'...
                            Exp.Current.taskMsg '\n\n'...
                            Exp.Text.readyMsg];
                    end
                    
                case 'TEST'
                    switch Exp.Current.Condition
                        case 'BL'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.BaselineT;
                        case 'SW'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.Switch;
                        case 'HO'
                            Exp.Current.taskMsg = Exp.Text.taskMsg.Hold;
                    end
                    
                    Exp.Current.Text = ['Exp?rience\n\n'...
                        'Bloc ' num2str(Exp.Current.Block) '\n\n'...
                        'Essai ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Parameters.LengthOfBlocks) '\n\n'...
                        Exp.Current.taskMsg '\n\n'...
                        Exp.Text.readyMsg];
            end
        end
        
end
end
