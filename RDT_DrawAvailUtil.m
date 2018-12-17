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

% Filename: RDT_DrawAvailUtil.m
% Author: M Shahrad
% Description: Draws figures related to availability maps


figure('Visible','on')
property_per_type = 3;
pm_types_count = length(pm_types);
for i=1:pm_types_count
    subplot(property_per_type,pm_types_count,i)
    pm_availability_map = reshape(pm_availability(i,:,:),[max([pm_types.pm_counts]),max([pm_types.cpu_per_pm])]);
    imagesc(pm_availability_map(1:pm_types(i).pm_counts,1:pm_types(i).cpu_per_pm))
    str = sprintf('Availability Map for PM Type %d',i);
    title(str)
    ylabel('PM #')
    xlabel('CPU #')
    caxis([0,1])
    colorbar
end

% figure % mips util maps
for i=1:pm_types_count
    subplot(property_per_type,pm_types_count,pm_types_count+i)
    imagesc(pm_types(i).mips_util/pm_types(i).cpu_mips)
    caxis([0,1])
    colorbar
    str = sprintf('MIPS Util Map for PM Type %d',i);
    title(str)
end

for i=1:pm_types_count
    subplot(property_per_type,pm_types_count,2*pm_types_count+i)
    hold on
    plot(pm_types(i).memory_util/pm_types(i).memory_per_pm)
    plot(pm_types(i).storage_util/pm_types(i).storage_per_pm)
    plot(pm_types(i).bandwidth_util/pm_types(i).bandwidth_per_pm)
    str = sprintf('Other Util PM Type %d',i);
    title(str)
    xlabel('PM #')
    legend('Mem','Str','BW');
end

if save_fig==1
    str = sprintf('./temp_res/AvailUtilAt%d.fig',time);
    saveas(gcf,str)
end