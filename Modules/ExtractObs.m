% Script to sort 1st percept observations
% created on 19/06/2018
% by Kevin Parisot
% v2 : new data sorting - take percepts only
% v3 : take out 1st percept for 'long' (17/07/2018)

function [Observations] = ExtractObs(Exp, arg)
MODE = 2;
switch MODE
    case 1
        x_obs = nan(1,Exp.Parameters.NumberOfTrialsPerCond(1));
        y_obs = nan(1,Exp.Parameters.NumberOfTrialsPerCond(1));
        for trial = 1 : Exp.Parameters.NumberOfTrialsPerCond(1)
            % we do the model only using alpha1, as we have a systematic diagonal,
            % we can obtain alpha2 systematically:
            x_obs(trial) = Exp.Data.TEST(1).Trial(trial).TrialInfo.Alphas(1);
            
            % we extract the responses and compute a percept based on that:
            % Pour un essai, on extrait:
            oriOffset_ = Exp.Data.TEST(1).Trial(trial).TrialInfo.BaseLineOrientation;
            alphas_ = Exp.Data.TEST(1).Trial(trial).TrialInfo.Alphas;
            response_ = Exp.Data.TEST(1).Trial(trial).Response;
            % On corrige la r?ponse:
            response_(1) = response_(1) - Exp.PTB.w/2;
            response_(2) = -(response_(2) - Exp.PTB.h/2);
            response_(3) = response_(3) - Exp.Data.TEST(1).Trial(trial).StimStart;
            [th, r] = cart2pol(response_(1),response_(2));
            %     th = rad2deg(th) - oriOffset_;
            if th < 0
                th = th + 1;%360;
            elseif th > 1;%360
                th = th - 1;%360;
            end
            y_obs(trial) = th;
        end
        %% 2e version
    case 2
        %         x_obs = nan(Exp.Parameters.NumberOfTrialsPerCond(1)+Exp.Parameters.NumberOfTrialsPerCond(2),1);
        %         y_obs = nan(Exp.Parameters.NumberOfTrialsPerCond(1)+Exp.Parameters.NumberOfTrialsPerCond(2),2);
        x_obs = [];
        y_obs = [];
        switch Exp.Current.Condition
            case 'Short'
                for trial = 1 : Exp.Parameters.NumberOfTrialsPerCond(1)
                    %                     x_obs(trial) = Exp.Data.TEST(1).Trial(trial).TrialInfo.Alphas(1);
                    %                     y_obs(trial,:) = [Exp.Data.TEST(1).Trial(trial).Perception(2,1) , 1];
                    x_obs = [x_obs ; Exp.Data.TEST(1).Trial(trial).TrialInfo.Alphas(1)];
                    y_obs = [y_obs ; Exp.Data.TEST(1).Trial(trial).Perception(2,1) , 1];
                end
            case 'Long'
                for trial = 1 : Exp.Parameters.NumberOfTrialsPerCond(1)
                    %                     x_obs(trial) = Exp.Data.TEST(1).Trial(trial).TrialInfo.Alphas(1);
                    %                     y_obs(trial,:) = [Exp.Data.TEST(1).Trial(trial).Perception(2,1) , 1];
                    x_obs = [x_obs ; Exp.Data.TEST(1).Trial(trial).TrialInfo.Alphas(1)];
                    y_obs = [y_obs ; Exp.Data.TEST(1).Trial(trial).Perception(2,1) , 1];
                end
                for trial = 1 : arg(1)-1
                    %                     x_obs(Exp.Parameters.NumberOfTrialsPerCond(1)+trial) = Exp.Data.TEST(2).Trial(trial).TrialInfo.Alphas(1);
                    X = [Exp.Data.TEST(2).Trial(trial).TrialInfo.Alphas(1);
                        Exp.Data.TEST(2).Trial(trial).TrialInfo.Alphas(1);
                        Exp.Data.TEST(2).Trial(trial).TrialInfo.Alphas(1)];
                    if size(Exp.Data.TEST(2).Trial(trial).Perception, 1) > 1
                        D = Exp.Data.TEST(2).Trial(trial).Perception;
                        D(D(:,1)==0,:) = [];D(D(:,1)==110,:) = [];D(D(:,1)==101,:) = [];D(D(:,1)==11,:) = [];
                        D(end,end) = Exp.Data.TEST(2).Trial(trial).StimFinish;
                        D(:,2:end) = D(:,2:end) - Exp.Data.TEST(2).Trial(trial).StimStart;
                        D(1,:) = []; % on vire le 1st percept
                        if not(isempty(D))
                            T = abs((D(:,4)-D(:,3))) ./ sum(abs((D(:,4)-D(:,3))));
                            DD(1,:) = [1, sum(T(D(:,1)==1))];
                            DD(2,:) = [10, sum(T(D(:,1)==10))];
                            DD(3,:) = [100, sum(T(D(:,1)==100))];
                            x_obs = [x_obs ; X];
                            y_obs = [y_obs ; DD];
                            %                     else
                            %                         DD = [];
                        end
                    end
                end
        end
        Observations = [x_obs, y_obs];
end