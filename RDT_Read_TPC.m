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

% Filename: RDM.m
% Author: M Shahrad
% Description: Reads and compares TotProviderCost data files


draw_fig_after_file_read = 1;

day = 86400;
month = 2592000;
sim_step = 5*60;            % 5 minutes
sim_duration = 12*month;    % 12 months
cost_period = 10*day;

% NOTE: Points the following paths to the correct temp_res/TotProviderCost.out files.
TotProviderCost_file_with_AK = ''
TotProviderCost_file_without_AK = ''

tpc_AK = dlmread(TotProviderCost_file_with_AK);
tpc_NOAK  = dlmread(TotProviderCost_file_without_AK);
plot_color = 'k';

x_val = sim_step:sim_step:sim_duration;

pc_AK = diff(tpc_AK);
pc_NOAK = diff(tpc_NOAK);

if draw_fig_after_file_read==1
    subplot(2,2,1);
    hold on
    plot(x_val/month,(tpc_NOAK-tpc_AK),plot_color);
    grid on
    xlabel('Month');
    ylabel('Total Cost Saving');
    %legend('Limited SLA Avail. Options','Arbitrary SLA Avail.','Location','best');
    
    subplot(2,2,2);
    hold on
    plot(x_val/month,tpc_AK./tpc_NOAK,plot_color);
    grid on
    xlabel('Month');
    ylabel('Cost Ratio (AK/NOAK)');
    
    subplot(2,2,3);
    split_index = floor(linspace(1,length(x_val),1+sim_duration/cost_period));
    pc_in_cp_AK = zeros(1,sim_duration/cost_period);
    pc_in_cp_NOAK = zeros(1,sim_duration/cost_period);
    for i=1:length(pc_in_cp_AK)
        pc_in_cp_AK(i) = tpc_AK(split_index(i+1)) - tpc_AK(split_index(i));
        pc_in_cp_NOAK(i) = tpc_NOAK(split_index(i+1)) - tpc_NOAK(split_index(i));
    end
    
    plot(pc_in_cp_AK./pc_in_cp_NOAK);
    grid on
    xlabel('Month');
    ylabel('Monthly Cost Ratio (A/N)');
   
    subplot(2,2,4)
    benefit = pc_AK./pc_NOAK;
    %s_benefit = smooth(benefit,month/1000+1,'sgolay');
    s_benefit = smooth(benefit,9,'sgolay');
    %s_benefit = smooth(benefit,15,'moving'); % 5 min
    %s_benefit = smooth(benefit,1555,'loess');% 15 min
    %scatter(x_val(1:end-1)/month,benefit,1,'r');
    %hold on
    plot(x_val(1:end-1)/month,s_benefit);
    str = sprintf('Mean: %d',mean(s_benefit));
    title(str);
    grid on
    xlabel('Month');
    ylabel('AK/NOAK');
end