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

% Filename: RDT_DDT_Gaurd.m
% Author: M Shahrad
% Description: Shapes the DDT gaurd


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