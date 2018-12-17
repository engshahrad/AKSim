% Copyright (c) 2018 Princeton University
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in the
%       documentation and/or other materials provided with the distribution.
%     * Neither the name of Princeton University nor the
%       names of its contributors may be used to endorse or promote products
%       derived from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
% (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
% (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Filename: RDT_DrawUserAvail.m
% Author: M Shahrad
% Description: Draws figures related to user availability & Provider Unit Cost

% figure('Visible','on')
% 
% subplot(3,2,[1,2]);
% [user_avail_sorted,user_avail_sorted_index] = sort(user_availability);
% user_avail_sla = [user.downtime_sla];
% [user_avail_sla_sorted,user_avail_sla_sorted_index] = sort(user_avail_sla);
% plot(1:user_count,user_availability(user_avail_sla_sorted_index),'b',1:user_count,user_avail_sla_sorted,'r');
% xlabel('User #');
% ylabel('Availability');
% legend('Real','SLA','Location','southeast');
% 
% subplot(3,2,3);
% plot(sort(user_availability))
% title('Sorted');
% ylabel('Availability');
% 
% subplot(3,2,4);
% hist(user_availability,4*user_count)
% title('Histogram');
% xlabel('Availability');
% ylabel('Freq');
% 
% subplot(3,2,[5,6]);
% semilogy(sort([user.tot_downtime]./((1-[user.downtime_sla]).*[user.tot_runtime])),'b*');
% hold on
% grid on
% semilogy(ones(1,user_count),'--k');
% title('Real Downtime over SLA Downtime');
% 
% if save_fig==1
%     str = sprintf('./temp_res/ServiceAvailability.fig');
%     saveas(gcf,str)
% end
% 
% figure('Visible','on')
% user_unit_cost = [user.net_cost]./[user.tot_runtime];
% subplot(2,2,1)
% scatter(user_availability,user_unit_cost,'b');
% grid on
% legend('Real','Location','best');
% ylabel('Provider Unit Cost');
% % hold on
% subplot(2,2,2)
% scatter([user.downtime_sla],user_unit_cost,'r');
% grid on
% legend('SLA','Location','best');
% set(gca, 'XScale', 'log')
% 
% subplot(2,2,3)
% scatter([user.downtime_sla],user_availability);
% grid on
% xlabel('Desired');
% ylabel('Delivered');
% 
% subplot(2,2,4)
% scatter(sla_downtime,user_availability);
% grid on
% xlabel('Desired');
% ylabel('Delivered');
% str = sprintf('TotProviderCost: %d',sum([user.net_cost]));
% title(str);
% 
% if save_fig==1
%     str = sprintf('./temp_res/ProviderUnitCost.fig');
%     saveas(gcf,str)
% end
% if save_data==1
%     dlmwrite('./temp_res/AvailabilityData.out',[user_availability;[user.downtime_sla];user_unit_cost]); % '-append' option removed
%     dlmwrite('./temp_res/TotProviderCost.out',tot_provider_cost);
% end

figure

subplot(3,1,1)
imagesc(user_availability')
caxis([0,1])
colorbar
xlabel('User');
ylabel('Month');

subplot(3,1,2)
downtime_fulfillment = zeros(user_count,ceil(time/measurement_period));
for i=1:user_count
    for j=1:ceil(time/measurement_period)
        downtime_fulfillment(i,j) = (user(i).downtime_sla*user(i).tot_runtime(j) - user(i).tot_downtime(j))/(user(i).downtime_sla*user(i).tot_runtime(j));
    end
end
imagesc(downtime_fulfillment')
caxis([0,1])
colorbar
xlabel('User');
ylabel('Month');

subplot(3,1,3)
[s1,s2] = size(downtime_fulfillment);
downtime_fulfillment_long = reshape(downtime_fulfillment,[s1*s2,1]);
plot(sort(downtime_fulfillment_long))
title('Downtime Fulfillment');

if save_fig==1
    str = sprintf('./temp_res/ServiceAvailability.fig');
    saveas(gcf,str)
end