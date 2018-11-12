%% Bulding reactivation models for VMs

% loop over all PM types
for i=1:length(user_app_groups)
    
    nums_to_fit = 10000;
    mu = user_app_groups(i).vm_react_mean;
    sigma = mu/10;
    pd_ref= makedist('Normal',mu,sigma);
    data_to_fit = random(pd_ref,[1,nums_to_fit]);
    VM_react_pd(i) = fitdist(data_to_fit','Gamma');
    
end