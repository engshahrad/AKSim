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

% Filename: RDT_DrawAvailPrice.m
% Author: M Shahrad
% Description: Draws some plots from avail_price_record data.


avail_price_record = dlmread('./temp_res/AvailPriceRec.out');
% DS Reminder-> [UserID,period,Req.Avail,Del.Avail,Price]

figure
subplot(1,3,1)
scatter(avail_price_record(:,3),avail_price_record(:,4),'.');
xlabel('Requested Availability');
ylabel('Delivered Availability');
subplot(1,3,2)
scatter(avail_price_record(:,3),avail_price_record(:,5),'.');
xlabel('Requested Availability');
ylabel('Price');
subplot(1,3,3)
scatter(avail_price_record(:,4),avail_price_record(:,5),'.');
xlabel('Delivered Avail');
ylabel('Price');

if save_fig==1
    str = sprintf('./temp_res/AvailPrice.fig');
    saveas(gcf,str)
end
