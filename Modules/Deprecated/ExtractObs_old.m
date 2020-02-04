% Script to sort 1st percept observations
% created on 18/06/2018
% by Kevin Parisot
% v1

function [x_obs, y_obs] = ExtractObs_old(Exp)
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