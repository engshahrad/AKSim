%% Saves relevant data

if save_data==1
    dlmwrite('./temp_res/SortedDTf.out', sort(downtime_fulfillment_long));
    dlmwrite('./temp_res/TotProviderCost.out', tot_provider_cost);
    dlmwrite('./temp_res/ProviderProfit.out', provider_profit);
    dlmwrite('./temp_res/AvailPriceRec.out', avail_price_record);
    dlmwrite('./temp_res/PMUtil.out', pm_utilization);
    dlmwrite('./temp_res/CPUUtil.out', cpu_utilization);
end