%% Creates the user availability SLA values with a certain distribution

switch user_avail_dist
    case 'Uniform'
        sla_downtime = 1 - 60.*randi([round(12*month*(1-downtime_dic(end))/60) round(12*month*(1-downtime_dic(1))/60)], 1, user_count)./(12*month);
    case 'Normal'
        sla_dt_pd = makedist('Normal');
        sla_dt_pd.mu = 1 - (downtime_dic(1)+downtime_dic(end))/2;
        sla_dt_pd.sigma = sla_dt_pd.mu/4;
        sla_dt = random(sla_dt_pd, [1,user_count]);
        sla_downtime = (1 - sla_dt)./ones(1,user_count);
        sla_downtime(sla_downtime>downtime_dic(end)) = downtime_dic(end);
    case 'Bimodal'
        sla_dt_pd = makedist('Normal');
        sla_dt_pd.mu = 1 - downtime_dic(1);
        sla_dt_pd.sigma = sla_dt_pd.mu/4;
        sla_dt = random(sla_dt_pd, [1,user_count]);
        sla_downtime = (1 - sla_dt)./ones(1,user_count);
        for i=1:user_count
            if sla_downtime(i) < downtime_dic(1)
                sla_downtime(i) = downtime_dic(end) - (downtime_dic(1)-sla_downtime(i));
            end
        end
end