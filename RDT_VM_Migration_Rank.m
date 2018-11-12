%% Determines the order of Benign VMs ready to be migrated to cheaper resources (BVM)

% update the DT_fulfillment of this period for all users
for i=1:user_count
    downtime_fulfillment(i,period) = (user(i).downtime_sla*user(i).tot_runtime(period)-user(i).tot_downtime(period))/(user(i).downtime_sla*user(i).tot_runtime(period));
end

decision_var = downtime_fulfillment(:,period);
[dec_var_val, dec_var_index] = sort(decision_var);