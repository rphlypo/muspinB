function plotLogisticSamples(X, b0, b1)

% plotting logistic samples

alphas_ = linspace(0, 1, 101);

sigmoid = @(x, b0, b1) 1 ./ (1 + exp(-b1 * (x - b0)));

percepts = {'tr', 'tl', 'coh'};
percept_code = [10, 1, 100];
percept = X(:, 2);
for jj = 1:length(percepts), % defines logical indices tl, tr, coh
    eval(sprintf('%s = percept == %i;', percepts{jj}, percept_code(jj)));
end
% tl = percept == 1;
% tr = percept == 10;
% coh = percept == 100;

alphas = struct();

for jj = 1:length(percepts),
    alphas.(percepts{jj}) = X(eval(percepts{jj}), 1); 
    a = alphas.(percepts{jj});
    
    s = plot(a, ones(length(a), 1), 'o', 'markersize', 10); hold all
    switch percepts{jj},
        case 'tl' % left
            plot(alphas_, sigmoid(1 - alphas_, b0, b1), 'color', get(s, 'color'));
        case 'tr' % right
            plot(alphas_, sigmoid(alphas_, b0, b1), 'color', get(s, 'color'));
        case 'coh' % coherence
            plot(alphas_, 1 - sigmoid(1 - alphas_, b0, b1) - sigmoid(alphas_, b0, b1), 'color', get(s, 'color'));
    end
end


plot(alphas_, -sigmoid(alphas_, b0, b1).*log(sigmoid(alphas_, b0, b1)) ...
    -sigmoid(1-alphas_, b0, b1).*log(sigmoid(1-alphas_, b0, b1)) ...
    -(1 - sigmoid(1 - alphas_, b0, b1) - sigmoid(alphas_, b0, b1)).* ...
    log(1 - sigmoid(1 - alphas_, b0, b1) - sigmoid(alphas_, b0, b1)));
    