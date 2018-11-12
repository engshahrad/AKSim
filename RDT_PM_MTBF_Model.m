%% Bulding failure models for PMs

% loop over all PM types
for i=1:length(pm_types)
    
    nums_to_fit = 500;      % deliberately given a small number to add noise
    mu = pm_types(i).mtbf;
    sigma = mu/10;
    %pd_ref= makedist('Normal',mu,sigma);
    pd_ref = makedist('Exponential',mu);
    data_to_fit = random(pd_ref,[1,nums_to_fit]);
    parmhat = wblfit(data_to_fit);
    PM_mtbf_pd(i) = makedist('Weibull','a',parmhat(1),'b',parmhat(2));
    
end