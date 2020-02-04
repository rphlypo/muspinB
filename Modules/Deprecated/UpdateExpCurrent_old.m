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
%         Exp.Current.Phase = arg;
    case 'Block'
        % What block are we in?
        
%         Exp.Current.BlockString = arg;
        Exp.Current.Block = arg;
%         Exp.Current.Condition = Exp.Parameters.Conditions;

        if strcmp(Exp.Current.Phase, 'LEARN')
            Exp.Current.Condition = Exp.Structure.Learn{Exp.Current.Block};
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
        switch Exp.Current.Phase
            case 'LEARN'
%                 Exp.Current.Condition = Exp.Parameters.Conditions{Exp.Structure.Learn.TrialMixValue(arg(1))};
%                 Exp.Current.Condition = Exp.Structure.Learn{Exp.Current.Block, Exp.Current.TrialInBlock};
            case 'TEST'
%                 Exp.Current.Condition = Exp.Parameters.Conditions{Exp.Structure.Test.TrialMixValue(arg(2))};
                Exp.Current.Condition = Exp.Structure.Test{Exp.Current.Block, Exp.Current.TrialInBlock};
        end
        
        % What are the alphas? 
%         Exp.Current.Alphas = [betarnd(Exp.Parameters.BetaParam(1), Exp.Parameters.BetaParam(2)), ...
%             betarnd(Exp.Parameters.BetaParam(1), Exp.Parameters.BetaParam(2))]; % expé kevin
        Exp.Current.Alphas = [Exp.Visual.Grating(1).globalAlpha, Exp.Visual.Grating(2).globalAlpha]; % expé florian
        
        % Adjust luminance and contrast depending on alphas picked:
        [Exp.Current.Luminance, Exp.Current.Contrast] = fLuminanceContrast(Exp.Current.Alphas, ...
            Exp.Visual.Common.bckcol2, Exp.Visual.Grating(1).mean, Exp.Visual.Grating(1).dutycycle);
        [Exp.Current.BetaLum, Exp.Current.OffsetLum] = fEgalisateur(Exp.Current.Luminance, Exp.Current.Contrast, ...
            Exp.Visual.Common.LuminanceRef, Exp.Visual.Common.ContrastRef);
        Exp.Current.GratingLum(1) = Exp.Current.BetaLum * Exp.Visual.Grating(1).mean + Exp.Current.OffsetLum;
        Exp.Current.GratingLum(2) = Exp.Current.BetaLum * Exp.Visual.Grating(2).mean + Exp.Current.OffsetLum;
        Exp.Current.BackGround = Exp.Current.BetaLum * Exp.Visual.Common.bckcol2 + Exp.Current.OffsetLum;
        
        % What parameters are we manipulating given the condition we are in?
%         Exp.Current.BaseLineOrientation = round(0 + (180-0).*rand(1,1));
%         % expé bottom up
        Exp.Current.BaseLineOrientation = 0; % expé top down
        
        % What phase shift? in pixels
        a = 0; b = 50;
        Exp.Current.PhaseShift = a + (b-a).*rand(1,1);
        
        % What are the jitter values? (for timing)
        a = .9; b = 1.3;
        Exp.Current.FixPointJit = a + (b-a).*rand(1,1);
        
        % What text to be displayed?
        switch Exp.Current.Phase
            case 'LEARN'
                switch Exp.Current.Condition
                    case 'BL'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.Baseline;
                    case 'SW'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.Switch;
                    case 'HO'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.Hold;
                    case 'LJ'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.LJ;
                end
                if strcmp(Exp.Current.Condition, 'LJ')
                    Exp.Current.Text = ['Entraînement - ' Exp.Current.Condition '\n\n'...
                    'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                    'Essai : ' num2str(Exp.Current.TrialInBlock) '\n\n'...
                    Exp.Current.taskMsg '\n\n'...
                    Exp.Text.readyMsg];
                else
                    Exp.Current.Text = ['Entraînement - ' Exp.Current.Condition '\n\n'...
                        'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
                        'Essai : ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Parameters.LengthOfBlocks) '\n\n'...
                        Exp.Current.taskMsg '\n\n'...
                        Exp.Text.readyMsg];
                end
                
            case 'TEST'
                switch Exp.Current.Condition
                    case 'BL'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.Baseline;
                    case 'SW'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.Switch;                        
                    case 'HO'
                        Exp.Current.taskMsg = Exp.Text.taskMsg.Hold;                        
                end
                
                Exp.Current.Text = ['Expérience\n\n'...
                    'Bloc ' num2str(Exp.Current.Block) '\n\n'...
                    'Essai ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Parameters.LengthOfBlocks) '\n\n'...
                    Exp.Current.taskMsg '\n\n'...
                    Exp.Text.readyMsg];
        end
                
%          switch Exp.Current.Phase
%             case 'FREE'
%                 Exp.Current.Text = ['Entraînement - ' Exp.Current.Condition '\n\n'...
%                     'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
%                     'Essai : ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Structure.Learn.NbTrials) '\n\n'...
%                     Exp.Text.taskLibre '\n\n'...
%                     Exp.Text.readyMsg];
%             case 'SWITCH'
%                 Exp.Current.Text = ['Entraînement - ' Exp.Current.Condition '\n\n'...
%                     'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
%                     'Essai : ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Structure.Learn.NbTrials) '\n\n'...
%                     Exp.Text.taskSwitch '\n\n'...
%                     Exp.Text.readyMsg];
%             case 'HOLD'
%                 Exp.Current.Text = ['Entraînement - ' Exp.Current.Condition '\n\n'...
%                     'Bloc : ' num2str(Exp.Current.Block) '\n\n'...
%                     'Essai : ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Structure.Learn.NbTrials) '\n\n'...
%                     Exp.Text.taskHold '\n\n'...
%                     Exp.Text.readyMsg];
%             case 'TEST'
%                 Exp.Current.Text = ['Expérience\n\n'...
%                     'Bloc ' num2str(Exp.Current.Block) '\n\n'...
%                     'Essai ' num2str(Exp.Current.TrialInBlock) ' sur ' num2str(Exp.Parameters.LengthOfBlocks) '\n\n'...
%                     Exp.Text.taskMsg '\n\n'...
%                     Exp.Text.readyMsg];
%         end
        
        
end
end
