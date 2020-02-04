function xyDown = f2DSmoothDownSampling(HighResolTrajectory, NbFrame, Fs, FLp)

NbSample = size(HighResolTrajectory, 2); 

%---------------------------------------
% Fs = 1000; %Hz
% FLp = 35; %HZ
[z,p,k] = butter(2,FLp/Fs*2,'low');
sos     = zp2sos(z,p,k);
[B,A] = sos2tf(sos);

% figure,
% % freqz(conv(B,fliplr(B)), conv(A,fliplr(A)),[],Fs); % check filter response
% freqz(B, A,[],Fs); % check filter response

xysmooth = zeros(size(HighResolTrajectory)); 

xysmooth(1, :) = filtfilt(B,A,HighResolTrajectory(1, :));
xysmooth(2, :) = filtfilt(B,A,HighResolTrajectory(2, :));


% figure
% subplot(1,3,1)
% plot(HighResolTrajectory(1, :), HighResolTrajectory(2, :), 'r-')
% hold on
% % plot(xydown(1, 10: end-10), xydown(2, 10:end-10), 'g-')
%  plot(xysmooth(1, :), xysmooth(2, :), 'g-')
% 
% subplot(1,3,2)
% plot(HighResolTrajectory(1, :), 'r-')
% hold on
% % plot(linspace(1,nbSample, nbPoint), xydown(1, :), 'g-')
% plot(xysmooth(1, :), 'b-')
% 
% subplot(1,3,3)
% plot(HighResolTrajectory(2, :), 'r-')
% hold on
% % plot(linspace(1,nbSample, nbPoint), xydown(2, :), 'g-')
% plot(xysmooth(2, :), 'b-')

xyDown=downsample(xysmooth',fix(NbSample/NbFrame))'; 
nbPnts = size(xyDown, 2); 

Delta = -NbFrame+nbPnts; 
Before = round(Delta/2);
After = Delta - Before; 

xyDown = xyDown(:, 1+Before : end -After); 



