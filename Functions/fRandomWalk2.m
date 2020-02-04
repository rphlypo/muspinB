% New random walk function for pilot 3 RDK generation
% Created by Kevin Parisot on 05/09/2018
% v1 (05/09/2018) = polar random walk
% v2 (05/09/2018) = use both polar and cartesian (working!)
% v3 (20/09/2018) = add lifetime of dot and handle coherence internally
% v4 (11/10/2018) = optimize lifetime generation

%% for dev:
% nDots=10000; nIter=1000; Version=4; DotLimit=30; nDim=2; VIZ = 1;  %type, Flags
%%
function [xDots, yDots] = fRandomWalk2(nDots, nIter, Version, DotLimit, nDim,  type, Flags)

Dots = nan(nDots, nIter, nDim);
xDots = nan(nDots, nIter);
yDots = nan(nDots, nIter);
switch Version
    case 1
        Dots(:,1,1) = DotLimit(1,1) + (DotLimit(1,2)-DotLimit(1,1)) .* rand(nDots,1); % radius
        Dots(:,1,2) = DotLimit(2,1) + (DotLimit(2,2)-DotLimit(2,1)) .* rand(nDots,1); % direction in radians
        
        for i = 2 : size(Dots,2)
            % sampling step size:
            if not(Flags(1))
                step = DotLimit(1) + (DotLimit(2)-DotLimit(1)) .* rand(nDots,1);
            else
                step = DotLimit(1) + (DotLimit(2)-DotLimit(1)) .* betarnd(.02, .02, 1);
            end
            Dots(:,i,1) = Dots(:,i-1,1) + step;
            % sampling angle:
            if (Flags(2))
                theta = DotLimit(2,1) + (DotLimit(2,2)-DotLimit(2,1)) .* rand(nDots,1);
            else
                switch type
                    case 'ROT'
                        if i > 50 && i < 150
                            theta = delta(1) + .01 .* randn(nDots,1);
                        else
                            theta = DotLimit(2,1) + (DotLimit(2,2)-DotLimit(2,1)) .* rand(nDots,1);
                        end
                        Dots(:,i,2) = Dots(:,i-1,2) + theta;
                    case 'IN'
                        if i > 50 && i < 150
                            theta = 0;
                        else
                            theta = DotLimit(2,1) + (DotLimit(2,2)-DotLimit(2,1)) .* rand(nDots,1);
                        end
                        Dots(:,i,2) = Dots(:,i-1,2) + theta;
                    case 'TRAN'
                        if i > 50 && i < 150
                            theta = 0;
                        else
                            theta = DotLimit(2,1) + (DotLimit(2,2)-DotLimit(2,1)) .* rand(nDots,1);
                        end
                        Dots(:,i,2) = theta;
                end
            end
            %             if FIG
            %                 [dotscart(:,i,1), dotscart(:,i,2)] = pol2cart(Dots(:,i,2),Dots(:,i,1));
            %                 plot(dotscart(:,i,1),dotscart(:,i,2), 'k.');
            %                 title(num2str(i))
            %                 lim = 100;
            % %                 axis([-lim, lim, -lim, lim])
            %                 pause(.1);
            %             end
        end
    case 2
        %         Dots(:,1,1) = randn(nDots,1);
        %         Dots(:,1,2) = randn(nDots,1);
        a = -DotLimit; b = DotLimit;
        [Dots(:,1,1), Dots(:,1,2)] = pol2cart(-pi + (pi+pi).*rand(nDots,1), a + (b-a).*rand(nDots,1));
        xDots(:,1) = Dots(:,1,1); yDots(:,1) = Dots(:,1,2);
        for i = 2 : size(Dots,2)
            Dots(:,i,1) = Dots(:,i-1,1) + randn(nDots,1);
            Dots(:,i,2) = Dots(:,i-1,2) + randn(nDots,1);
            [tDots, rDots] = cart2pol(Dots(:,i,1),Dots(:,i,2));
            
            for j = 1 : nDots
                if rDots(j) > DotLimit
                    rDots(j) = rDots(j) - rand;
                end
                
            end
            
            [xdots, ydots] = pol2cart(tDots, rDots);
            Dots(:,i,1) = xdots; Dots(:,i,2) = ydots;
            xDots(:,i) = xdots; yDots(:,i) = ydots;
        end
    case 3
        %% Generate lifetimes for each dot:
        Life = nan(nIter,nDots);
        for d = 1 : size(Dots,1)
            ll = 1; lu = size(Dots,2);
            i = 0; life = 0;
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
            Life(1:length(life),d) = life;
        end
%         Life(1,:) = [];
        
        %% Generate spatial trajectories
%         figure;hold on; grid
for d = 1 : nDots
    phases = Life(not(isnan(Life(:,d))),d);
    phase_ = 0;
    for p = 2 : length(phases)
        phase_ = phase_ + phases(p);
        i=phases(p-1); c=1;
        while i <= phase_
            i = i+1;
            if c == 1
                
                xDots(d,i) = randn;
                yDots(d,i) = randn;
            else
                xDots(d,i) = xDots(d,i-1) + randn;
                yDots(d,i) = yDots(d,i-1) + randn;
            end
            c = c+1;
            
            %                     Verify that we are not stepping out of limits
            if i < nIter
                [tDot, rDot] = cart2pol(xDots(d,i),yDots(d,i));
                k=0;
                while rDot > DotLimit
                    rDot = rDot + randn;
                    k = k+1;
                end
                [xDots(d,i), yDots(d,i)] = pol2cart(tDot, rDot);
            end
        end
        %             plot(xDots(d,:),yDots(d,:),'+-')
        %             plot(xDots,yDots,'+-')
    end
end
%         hold off
    case 4
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
            if Life(i,:) == 1
%                 xDots(:,i) = randn(nDots,1);
%                 yDots(:,i) = randn(nDots,1);
                xDots(:,i) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(nDots,1);
                yDots(:,i) = -DotLimit + (DotLimit - (-DotLimit)) .* rand(nDots,1);
            else
                xDots(:,i) = xDots(:,i-1) + randn(nDots,1);
                yDots(:,i) = yDots(:,i-1) + randn(nDots,1);
            end
            % Verify that we are not stepping out of limits
            [tDot, rDot] = cart2pol(xDots(:,i),yDots(:,i));
            rDot(rDot > DotLimit, :) = DotLimit;
            [xDots(:,i), yDots(:,i)] = pol2cart(tDot, rDot);
        end
end

%% Vizualise
% if VIZ
% figure; %hold on
% axis([-DotLimit, DotLimit, -DotLimit, DotLimit])
% for i = 1 : nIter
%     plot(xDots(:,i), yDots(:,i), 'k.');
%     pause(.01)
% end
% axis([-DotLimit, DotLimit, -DotLimit, DotLimit])
% % hold off
% end

%% Fun drawings
% to make a spiral use:
% [Dots] = fRandomWalk2(50, 100, 2, 'Polar', 'ROT', [0 0], [-sqrt(1^2 + 1^2), sqrt(1^2 + 1^2);-pi, pi]);