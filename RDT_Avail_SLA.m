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

% Filename: RDT_Avail_SLA.m
% Author: M Shahrad
% Description: Creates the user availability SLA values with a certain distribution

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