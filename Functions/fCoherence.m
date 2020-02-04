% Coherence phase preparation for pilot 3
% Created by Kevin Parisot on 06/09/2018
% v1 (06/09/2018) :

function [xDots, yDots, CohPhases, CoherencePhases, Percept, CoherenceTimeLine, DotIdx] = fCoherence(Exp)
%% Generate Dots coordinates
[xDots, yDots] = fRandomWalk2(Exp.Parameters.nDots, ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi)*2, 2, Exp.Parameters.DotLimit, 2);

%% Chose percept phase durations
CoherenceTimeLine = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi)*2, 1);
CohPhases = lognrnd(Exp.Parameters.LognRnd(1), Exp.Parameters.LognRnd(2));
while sum(CohPhases) < Exp.Parameters.TrialTimeOut
    CohPhases = [CohPhases, lognrnd(Exp.Parameters.LognRnd(1), Exp.Parameters.LognRnd(2))];
end
% Exp.Current.Particles.CoherencePhases = CoherencePhases;
CoherencePhases = cumsum(ceil(CohPhases/Exp.PTB.ifi));
% Exp.Current.Particles.CoherencePhasesCumulated = CoherencePhases;

%% Chose percepts
Percept = nan(size(CoherencePhases));
Percept(1) = 100;
for j = 2 : size(CoherencePhases,2)
    switch Percept(j-1)
        case 100
            poss = [1, 10];
            Percept(j) = poss(randi(2));
        case 10
            poss = [1, 100];
            Percept(j) = poss(randi(2));
        case 1
            poss = [100, 10];
            Percept(j) = poss(randi(2));
    end
end
% Exp.Current.Particles.Percept = Percept;

%% Create percept time line
if CoherencePhases(1) > size(CoherenceTimeLine,1)
    CoherenceTimeLine(1:end) = 100;
else
    k = 1;
    for i = 1 : size(CoherenceTimeLine,1)
        if i == CoherencePhases(k)
            if k == 1
                CoherenceTimeLine(1:CoherencePhases(k)) = Percept(k);
            else
                CoherenceTimeLine(CoherencePhases(k-1)+1:CoherencePhases(k)) = Percept(k);
            end
            k = k + 1;
            if k > size(CoherencePhases,2)
                k = size(CoherencePhases,2);
            end
        end
    end
    CoherenceTimeLine(CoherencePhases(k)+1:end) = Percept(k);
end
% Exp.Current.Particles.CoherenceTimeLine = CoherenceTimeLine;
%% Chose dots that will go coherent :
DotIdx = rand(Exp.Parameters.nDots,1) < Exp.Parameters.CohPerc / 100;
% Exp.Current.Particles.DotIdx = rand(Exp.Parameters.nDots,1) < Exp.Parameters.CohPerc / 100;

%% Transform xdots and ydots with percept timelines:
delta = ceil(Exp.Parameters.ManipTime/Exp.PTB.ifi); st = 1;
for i = 1 : size(Percept,2)
    if i > 1
        st = CoherencePhases(i-1);
    end
    switch Percept(i)
        case 100
            if i == size(Percept,2) && CoherencePhases(i) + delta > size(yDots,2)
                for j = st : size(yDots,2) - ceil(CoherencePhases(i)/Exp.PTB.ifi)
                    switch Exp.Parameters.Method
                        case 'Saccade'
                            yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                            xDots(DotIdx, j) = xDots(DotIdx, j);
                        case 'Pursuit'
                            yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                            xDots(DotIdx, j) = xDots(DotIdx, j);
                    end
                end
            else
                for j = st : st+delta
                    switch Exp.Parameters.Method
                        case 'Saccade'
                            yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                            xDots(DotIdx, j) = xDots(DotIdx, j);
                        case 'Pursuit'
                            if j > st+delta/2
                                yDots(DotIdx, j) = yDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                                xDots(DotIdx, j) = xDots(DotIdx, j);
                            else
                                yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                                xDots(DotIdx, j) = xDots(DotIdx, j);
                            end
                    end
                end
            end
        case 10
            if i == size(Percept,2) && CoherencePhases(i) + delta > size(yDots,2)
                for j = st : size(xDots,2) - ceil(CoherencePhases(i)/Exp.PTB.ifi)
                    switch Exp.Parameters.Method
                        case 'Saccade'
                    xDots(DotIdx, j) = xDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                        case 'Pursuit'
                    end
                end
            else
                for j = st : st+delta
                    switch Exp.Parameters.Method
                        case 'Saccade'
                    xDots(DotIdx, j) = xDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                        case 'Pursuit'
                            if j > st+delta/2                                
                    xDots(DotIdx, j) = xDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                            else
                    xDots(DotIdx, j) = xDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                            end
                    end
                end
            end
        case 1
           if i == size(Percept,2) && CoherencePhases(i) + delta > size(yDots,2)
                for j = st : size(xDots,2) - ceil(CoherencePhases(i)/Exp.PTB.ifi)
                    switch Exp.Parameters.Method
                        case 'Saccade'
                    xDots(DotIdx, j) = xDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                        case 'Pursuit'
                    end
                end
           else
                for j = st : st+delta
                    switch Exp.Parameters.Method
                        case 'Saccade'
                    xDots(DotIdx, j) = xDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                        case 'Pursuit'
                            if j > st+delta/2 
                    xDots(DotIdx, j) = xDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) + Exp.Parameters.CoherenceStep;
                            else
                    xDots(DotIdx, j) = xDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                    yDots(DotIdx, j) = yDots(DotIdx, j) - Exp.Parameters.CoherenceStep;
                            end
                    end
                end                
           end
    end
end

