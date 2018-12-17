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

% Filename: Read_OutFile.m
% Author: M Shahrad
% Description: Reads from saved data


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