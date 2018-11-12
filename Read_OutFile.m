% Reads from saved data

draw_fig_after_file_read = 1;

dlmread('results/1000user_5min_1year/rounded/AvailabilityData.out');
availability = ans(1,:);
downtime_sla = ans(2,:);
unit_cost = ans(3,:);

downtime_dic = [.99 .999 .9999 .99999];
cost = zeros(1,length(downtime_dic));
count = zeros(1,length(downtime_dic));

for i=1:length(downtime_sla)
    [val,index] = max(downtime_dic==downtime_sla(i));
    cost(index) = cost(index) + unit_cost(i);
    count(index) = count(index) + 1;
end

mean_unit_cost = cost./count;

if draw_fig_after_file_read==1
%      figure
%      scatter(downtime_sla,unit_cost);
%      xlabel('Requested Availability');
%      ylabel('Provider Unit Cost');
%      grid on
%      hold on
%      plot(downtime_dic,mean_unit_cost,'--r*');
%      figure 
%      scatter(downtime_sla,availability);
%      figure
%      scatter(availability,unit_cost);
%      xlabel('Provided Availability');
%      ylabel('Provider Unit Cost');
%      grid on
     figure
     subplot(1,2,1);
     scatter(downtime_sla_bu,availability_bu);
     plot_down_lim = 0.9985;
     plot_up_lim = 1;
     xlim([plot_down_lim plot_up_lim])
     ylim([plot_down_lim plot_up_lim])
     xlabel('Requested Availability');
     ylabel('Provided Availability');
     title('No Round');
     grid on
     hold on
     plot_diag = linspace(plot_down_lim,plot_up_lim,1000);
     plot(plot_diag,plot_diag,'--b');
     subplot(1,2,2);
     scatter(downtime_sla,availability);
     xlim([plot_down_lim plot_up_lim])
     ylim([plot_down_lim plot_up_lim])
     xlabel('Requested Availability');
     ylabel('Provided Availability');
     title('Rounded');
     grid on
     hold on
     plot_diag = linspace(plot_down_lim,plot_up_lim,1000);
     plot(plot_diag,plot_diag,'--b');
end