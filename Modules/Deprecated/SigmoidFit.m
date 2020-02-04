%% Prototype d'estimateur simple d'une sigmoid
% par Kevin Parisot, le 11 d?cembre 2017
clear; close all;


intx = [0 1];
inty = [0 1];
a = 10; b=5;
nsim = 100;
x_th = 0:.1:1;
y_th = 1 ./ (1 + exp(-a.*x_th + b));
nA = 0:.1:.9;

tic
for n = 1 : length(nA);
    % nsamples = 6;
    for nsamples = 1 : 10;
        % x = rand(1,nsamples);
        
        x = betarnd(.2, .2, nsim, nsamples);
        bornes = [.2 .8];
        x = bornes(1) + x .* (bornes(2) - bornes(1));
        noise = nA(n) .* randn(1,nsamples);
        y = nan(nsim,nsamples);
        for i = 1 : nsim
            y(i,:) = 1 ./ (1 + exp(-a.*x(i,:) + b)) + noise;
        end
        
        
        
        
        %% fit from the internet:
        A = [1, 1, a, b];
        A0 = ones(size(A)); %// Initial values fed into the iterative algorithm
        % A = ones(1,4);
        % sigfunc = @(A, x)(A(1) ./ (A(2) + exp(-A(3).*x + A(4))));
        
        for i = 1 : nsim
            sigfunc = @(A, x)(1 ./ (1 + exp(-A(3).*x + A(4))));
            % A0 = ones(1,2);
            A_fit(i,:) = nlinfit(x(i,:), y(i,:), sigfunc, A0);
            
            y_es(i,:) = A_fit(i,1) ./ (A_fit(i,2) + exp(-A_fit(i,3) .* x_th + A_fit(i,4)));
            err(i,nsamples) = (1/length(x_th)) .* sum((y_th - y_es(i,:)).^2);
        end
        
        
    end
    
    %%
    figure(1);
    subplot(5,2,n)
    plot(x,y,'o', 'LineWidth',2); hold on
    plot(x_th,y_th)
    plot(x_th, y_es);
    xlim(intx); ylim(inty);
    legend('data','theory','fit', 'Location', 'NorthWest')
    title(['Data - noise : ' num2str(nA(n))])
    xlabel('Parameter');ylabel('Observation');
    % mean(err)
    % std(err)
    % figure;
    % hist(err)
    
    figure(2);
    subplot(5,2,n)
    plot(mean(err,1), 'ko-', 'LineWidth', 2)
    hold on
    plot(mean(err,1)+std(err,1), 'k+')
    plot(mean(err,1)-std(err,1), 'k+')
    for i = 1 : nsamples
        plot([i i], [mean(err(:,i))+std(err(:,i)),mean(err(:,i))-std(err(:,i))], 'k+-')
    end
    title(['Evolution of MSE - noise : ' num2str(nA(n))])
    xlabel('Nb samples of obs'); ylabel('MSE')
    hold off
end
toc