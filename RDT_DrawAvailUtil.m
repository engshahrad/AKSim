% figure % availability maps
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