%% Shaping the DDT gaurd

RDT_Parameters
RDT_Avail_SLA

plot(sla_downtime,sla_downtime);

g1 = (1-0.85*(1-sla_downtime));
% g2_pow = 100;
% g2 = 1-(1-sla_downtime).*( (downtime_dic(1)./(sla_downtime)).^g2_pow );
a_0 = 0.9*(downtime_dic(end)-downtime_dic(1)) + downtime_dic(1);
s = (downtime_dic(end)-downtime_dic(1))/(a_0-downtime_dic(1));
g2 = s*(sla_downtime - downtime_dic(1)) + downtime_dic(1);
g2 = 1 - 0.95*(1-g2);

hold on
scatter(sla_downtime,g1,'.');
scatter(sla_downtime,g2,'.');

legend('base','15%','Location','SouthEast');