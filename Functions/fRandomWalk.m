function XYRandomWalk = fRandomWalk(StartingFix, DurationFix, Amplitude, scale)

Threshold = 10; 
XYRandomWalk = zeros(DurationFix, 2); %from the origin point

if ~isempty(scale) %Constraint n the random walk
    for idx = 2 : DurationFix %at each gaze sample, a step in the random walk
        Rho = norm(XYRandomWalk(idx-1, :));
        if Rho > Threshold
        CurrentTeta = atan2(XYRandomWalk(idx-1, 2),XYRandomWalk(idx-1, 1)); 
        teta = norminv( rand, CurrentTeta+pi, scale / Rho );  
        else
            teta = rand(1)*2*pi;
        end
        CurrentXY(1) = XYRandomWalk(idx-1, 1)+ Amplitude(idx)*cos(teta);
        CurrentXY(2) = XYRandomWalk(idx-1, 2)+ Amplitude(idx)*sin(teta);
        XYRandomWalk(idx, :) = CurrentXY;
    end
else %No constraint
    for idx = 2 : DurationFix %at each gaze sample, a step in the random walk
        teta = rand(1)*2*pi;
        CurrentXY(1) = XYRandomWalk(idx-1, 1)+ Amplitude(idx)*cos(teta);
        CurrentXY(2) = XYRandomWalk(idx-1, 2)+ Amplitude(idx)*sin(teta);
        XYRandomWalk(idx, :) = CurrentXY;
    end 
end

%translation from the starting point
XYRandomWalk = XYRandomWalk + ones(DurationFix, 1)*StartingFix;



