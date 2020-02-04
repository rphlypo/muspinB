function [traj] = fGenLissajouT(t, amp, fv, fh, phi)
% with,
% N: number of samples
% a: amplitude parameter
% p, q: symmetry parameters
% phi: phase parameter
% sr: sample rate

theta = t * 2 * pi;
traj = [amp*sin(fv*theta),  amp*sin(fh*theta + phi)];

end

% lignes de codes dans le script

  

% amp=20, fv=.4, fh=pi/7, phi=0,% ligne mise dans la partie "OPTION SELECTOR"
% 
% %Partie Animation loop
%  Trajectory = nan(ceil(Exp.Parameters.TrialTimeOut/Exp.PTB.ifi),3);
% 
% % Partie " TRIALON "
% traj = fGenLissajouT(vbl+Exp.PTB.ifi*3/2, amp, fv, fh, phi);
%                 x = traj(1)+Exp.PTB.w/2; y = traj(2)+Exp.PTB.h/2;
%                Screen('DrawDots', win, [x, y], Exp.Visual.Common.dotSize, Exp.Visual.Common.dotcol, [], 2);
%                
%                  Trajectory(cnt,1) = x;
%                 Trajectory(cnt,2) = y;
%                 Trajectory(cnt,3) = GetSecs;
%  % en fin de boucle while TRIAL ON
%   Exp.Data.(Exp.Current.Phase)(Exp.Current.Block).Trial(Exp.Current.TrialInBlock).Trajectory = [Trajectory(not(isnan(Trajectory(:,1))),1), Trajectory(not(isnan(Trajectory(:,2))),2), Trajectory(not(isnan(Trajectory(:,3))),3)];              
%                 
%                 
%                 
%   
