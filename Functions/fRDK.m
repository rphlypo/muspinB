% New random walk function for pilot 3 RDK generation
% Created by Kevin Parisot on 05/09/2018
% v1 (05/09/2018) = polar random walk
% v2 (05/09/2018) = use both polar and cartesian (working!)
% v3 (20/09/2018) = add lifetime of dot and handle coherence internally
% v4 (11/10/2018) = optimize lifetime generation
% v5 (15/10/2019) = add coherent dots to make it a RDK

% %% for dev:
% clear; close all;
% nDots=1000; nIter=1000; DotLimit=30; nDim=2; VIZ = 1;  %type, Flags
% CohrencePerc = .01; CohStep = .05;

%%
function [xDots, yDots, DotCoh, DotRW, Life] = fRDK(nDots, nIter, DotLimit, nDim, CohrencePerc, CoherenceStep, Percept)

Dots = nan(nDots, nIter, nDim);
xDots = nan(nDots, nIter);
yDots = nan(nDots, nIter);

%% Select coherent dots
DotCoh = rand(nDots,1) < CohrencePerc;
DotRW = DotCoh == 0;

%% Select coherent step as a function of percept:
switch Percept
    case 1
        CohStep = [-CoherenceStep, -CoherenceStep];
    case 10
        CohStep = [CoherenceStep, -CoherenceStep];
    case 100
        CohStep = [0, -CoherenceStep];
end

%% Generate lifetimes for each dot:
Life = zeros(nIter,nDots);
for d = 1 : size(Dots,1)
    ll = 1; lu = size(Dots,2);
    i = 0; life = 1;
    while sum(life) < lu
        i = i + 1;
        life_ = ceil(ll + (lu-ll) .* rand);
        life = [life, life_];
    end
    if i > 1 && life(end) > (lu - sum(life))
        life(end) = lu - sum(life(1:end-1));
    elseif i == 1 && life(end) > lu
        life(end) = lu;
    end
    Life(cumsum(life),d) = 1;
end

%% Generate spatial trajectories
for i = 1 : nIter
    %     if sum(Life(i,:)) > 1 %Life(i,:) == 1
    % rw:
    xDots(Life(i,DotRW) == 1,i) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(sum(Life(i,DotRW) == 1),1);
    yDots(Life(i,DotRW) == 1,i) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(sum(Life(i,DotRW) == 1),1);
    % coh:
    xDots(Life(i,DotCoh) == 1,i) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(sum(Life(i,DotCoh) == 1),1);
    yDots(Life(i,DotCoh) == 1,i) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(sum(Life(i,DotCoh) == 1),1);
    %     else
    if sum(Life(i,DotRW) == 0) > 0
        % rw:
        xDots(Life(i,DotRW) == 0,i) = xDots(Life(i,DotRW) == 0,i-1) + randn(sum(Life(i,DotRW) == 0),1);
        yDots(Life(i,DotRW) == 0,i) = yDots(Life(i,DotRW) == 0,i-1) + randn(sum(Life(i,DotRW) == 0),1);
    end
    if sum(Life(i,DotCoh) == 0) > 0
        % coh:
        xDots(Life(i,DotCoh) == 0,i) = xDots(Life(i,DotCoh) == 0,i-1) + CohStep(1).*ones(sum(Life(i,DotCoh) == 0),1);
        yDots(Life(i,DotCoh) == 0,i) = yDots(Life(i,DotCoh) == 0,i-1) + CohStep(2).*ones(sum(Life(i,DotCoh) == 0),1);
    end
    % Verify that we are not stepping out of limits
    [tDot, rDot] = cart2pol(xDots(:,i),yDots(:,i));
%     rDot(rDot(DotRW) > DotLimit, :) = DotLimit;
    if sum(rDot(DotCoh) > DotLimit) > 0
        rDot(rDot(DotCoh) > DotLimit, :) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(sum(rDot(DotCoh) > DotLimit),1);
    end
    rDot(rDot > DotLimit, :) = DotLimit;
    [xDots(:,i), yDots(:,i)] = pol2cart(tDot, rDot);
end

% %% Vizualise
% if VIZ
% figure; %hold on
% axis([-DotLimit, DotLimit, -DotLimit, DotLimit])
% for i = 1 : nIter
%     plot(xDots(:,i), yDots(:,i), 'k.');
% axis([-DotLimit, DotLimit, -DotLimit, DotLimit])
%     pause(.01)
% end
% axis([-DotLimit, DotLimit, -DotLimit, DotLimit])
% % hold off
% end
