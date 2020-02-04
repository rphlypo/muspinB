%% Prototype d'un ?chantillonneur de valeurs selon une loi Beta born?e
% par Kevin Parisot, le 11 d?cembre 2017

clear; close all; 

param = .25;
nsample = 5;
X = 0:.01:1;
% y1 = betapdf(X,0.75,0.75);
y1 = betapdf(X,param,param);
y2 = betapdf(X,1,1);
y3 = betapdf(X,4,4);

y_r = betarnd(param,param, 1,nsample);

figure
plot(X,y1,'Color','r','LineWidth',2)
hold on
plot(X,y2,'LineStyle','-.','Color','b','LineWidth',2)
plot(X,y3,'LineStyle',':','Color','g','LineWidth',2)
legend({'a = b = 0.25','a = b = 1','a = b = 4'},'Location','NorthEast');
hold off