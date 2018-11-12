%% Draws some plots from avail_price_record data.

avail_price_record = dlmread('./temp_res/AvailPriceRec.out');
% DS Reminder-> [UserID,period,Req.Avail,Del.Avail,Price]

figure
subplot(1,3,1)
scatter(avail_price_record(:,3),avail_price_record(:,4),'.');
xlabel('Req. Avail');
ylabel('Del. Avail');
subplot(1,3,2)
scatter(avail_price_record(:,3),avail_price_record(:,5),'.');
xlabel('Req. Avail');
ylabel('Price');
subplot(1,3,3)
scatter(avail_price_record(:,4),avail_price_record(:,5),'.');
xlabel('Del. Avail');
ylabel('Price');

if save_fig==1
    str = sprintf('./temp_res/AvailPrice.fig');
    saveas(gcf,str)
end