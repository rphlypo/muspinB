function [traj] = fGenLissajou(N, a, p, q, phi, sr)
% with,
% N: number of samples
% a: amplitude parameter
% p, q: symmetry parameters
% phi: phase parameter
% sr: sample rate

t = sr:sr:sr*N;
theta = t * 2 * pi;
traj(:,1) = a*sin(p*theta);
traj(:,2) = a*sin(q*theta + phi);

end