% Function for Random Dot Kinematogram generation using the principle of
% 'direction' as the manipulated parameter. Dots are born with either the
% signal or noisy direction and follow a lifetime.
function [dots] = fDirectionRDK(nDots, color, size, center, apertureSize, ...
    speed, duration, direction, lifetime, noiseProportion, display)
% Parameters :
dots.nDots = nDots; %1000;                % number of dots
dots.color = color; %[255,255,255]./2;      % color of the dots
dots.size = size; %1;                   % size of dots (pixels)
dots.center = center; %[0,0];           % center of the field of dots (x,y)
dots.apertureSize = apertureSize; %[2, 2]; %[1.5,1.5];     % size of rectangular aperture [w,h] in degrees.

dots.speed = speed; %1;       %degrees/second
dots.duration = duration; %5;    %seconds
dots.direction = direction; %0;  %degrees (clockwise from straight up)

dots.lifetime = lifetime; %50000;  %lifetime of each dot (seconds)

% First we'll calculate the left, right top and bottom of the aperture (in
% degrees)
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

secs2frames = @(frameRate, duration) ceil(duration * frameRate);

% Initiatlisation :
% New random starting positions
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

nFrames = secs2frames(display.frameRate, dots.duration);
dx_const = dots.speed(1)*sin(dots.direction*pi/180)/display.frameRate;
dy_const = -dots.speed(2)*cos(dots.direction*pi/180)/display.frameRate;
[dth, dr] = cart2pol(dx_const, dy_const);
dots.dir = dth .* ones(1,dots.nDots);
noisyDots = rand(dots.nDots,1) < noiseProportion;
noisyDots = sort(noisyDots);
cohDots = noisyDots == 0;

newDotsNoisy = logical(noisyDots');
noise = -pi + (pi + pi) .* rand(1,dots.nDots);
if not(isempty(dots.dir(newDotsNoisy)))
    dots.dir(newDotsNoisy) = noise(newDotsNoisy);
end

newDotsCoh = logical(cohDots');
if not(isempty(dots.dir(newDotsCoh)))
    temp = dth .* ones(1, nDots); %ones(size(dots.dir));
    dots.dir(newDotsCoh) = temp(newDotsCoh);
end
% Each dot will have a integer value 'life' which is how many frames the
% dot has been going.  The starting 'life' of each dot will be a random
% number between 0 and dots.lifetime-1 so that they don't all 'die' on the
% same frame:
dots.lifetimeframes = secs2frames(display.frameRate, dots.lifetime);
dots.life =    ceil(rand(1,dots.nDots)*dots.lifetimeframes);

dots.coordx = []; dots.coordy = []; dots.pixpos.x = []; dots.pixpos.y = [];

for i=1:nFrames
    %convert from degrees to screen pixels
    dots.pixpos.x = [dots.pixpos.x; angle2pix(display.width,display.resolution(1),display.dist, dots.x)+ display.resolution(1)/2];
    dots.pixpos.y = [dots.pixpos.y; angle2pix(display.width,display.resolution(1),display.dist, dots.y)+ display.resolution(2)/2];
%     dots.pixpos.x = angle2pix(display.width,display.resolution(1),display.dist, dots.x)+ display.resolution(1)/2;
%     dots.pixpos.y = angle2pix(display.height,display.resolution(2),display.dist, dots.y)+ display.resolution(2)/2;
    
    dots.coordx = [dots.coordx; dots.x];
    dots.coordy = [dots.coordy; dots.y];
    
    dots.goodDots(i,:) = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
        (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;
    
    %update the dot position
    dots.x(cohDots) = dots.x(cohDots) + dx_const; %+ Noise.*rand(size(dots.x));
    dots.y(cohDots) = dots.y(cohDots) + dy_const; %+ Noise.*rand(size(dots.y));
    [dots.th, dots.r] = cart2pol(dots.x, dots.y);
    
    [dx_temp, dy_temp] = pol2cart(dots.dir, dr);
    dots.x(noisyDots) = dots.x(noisyDots) + dx_temp(noisyDots);
    dots.y(noisyDots) = dots.y(noisyDots) + dy_temp(noisyDots);
    
    %move the dots that are outside the aperture back one aperture
    %width.
    dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
    dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
    dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
    dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);
    
    %increment the 'life' of each dot
    dots.life = dots.life+1;
    
    %find the 'dead' dots
    deadDots = mod(dots.life,dots.lifetimeframes)==0;
    
    %replace the positions of the dead dots to a random location
    dots.x(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(1) + dots.center(1);
    dots.y(deadDots) = (rand(1,sum(deadDots))-.5)*dots.apertureSize(2) + dots.center(2);
    newDotsNoisy = logical(noisyDots' .* deadDots);
    noise = -pi + (pi + pi) .* rand(1,dots.nDots);
    if not(isempty(dots.dir(newDotsNoisy)))
        dots.dir(newDotsNoisy) = noise(newDotsNoisy);
    end
    
    newDotsCoh = logical(cohDots' .* deadDots);
    if not(isempty(dots.dir(newDotsCoh)))
        temp = dth .* ones(1, nDots);
        dots.dir(newDotsCoh) = temp(newDotsCoh);
    end
    
end


%% to test it:
% figure
% for i = 1 : 300
%     plot(Exp.Current.Particles.coordx(i,Exp.Current.Particles.goodDots(i,:)),Exp.Current.Particles.coordy(i,Exp.Current.Particles.goodDots(i,:)),'o')
%     axis([-1, 1, -1, 1])
%     pause(.02)
% end