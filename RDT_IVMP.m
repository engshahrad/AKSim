%% Initial VM Placement

sla_downtime_penalty_vector = ones(length(pm_types),max([pm_types.pm_counts]));

 % find available PMs
 pm_availability = zeros(length(pm_types),max([pm_types.pm_counts]),max([pm_types.cpu_per_pm]));
 for i2=1:length(pm_types)                  % PM type iter
     for i3=1:pm_types(i2).pm_counts        % PM iter
%              % debug checkpoint
%              if (i1==105) && (i2==2)
%                  1
%              end
         if (pm_types(i2).status(i3) ~= 1)
             continue       % continue if PM not active
         end
          
         % check leftover memory
         if (pm_types(i2).memory_per_pm-pm_types(i2).memory_util(i3))<vm(i1).vm_memory
             continue               % PM not available for scheduling
         end
         % check leftover bandwidth
         if (pm_types(i2).bandwidth_per_pm-pm_types(i2).bandwidth_util(i3))<vm(i1).vm_bandwidth
             continue               % PM not available for scheduling
         end
         % check leftover storage
         if (pm_types(i2).storage_per_pm-pm_types(i2).storage_util(i3))<vm(i1).image_size
             continue               % PM not available for scheduling
         end
         % Accelerated CPU iter
         pm_availability(i2,i3,1:pm_types(i2).cpu_per_pm) = (pm_types(i2).cpu_mips-pm_types(i2).mips_util(i3,:)) > vm(i1).vm_mips;
     
         % check for SLA downtime if required to do so
         if check_downtime_sla==1
             % anticipated what happans to user downtime if only this VM is 
             % fails on specific PM (this is the worst case scenario)
             tot_predicted_TNF = user(vm(i1).user_id).tot_runtime(period) + (pm_types(i2).mtbf - (time-pm_types(i2).init_time(i3)) );  % total predicted time to next failure
             % let's consider the worst downtime due to migration w/o pre-copy
             tot_predicted_DT = user(vm(i1).user_id).tot_downtime(period) + 8*vm(i1).vm_memory/vm(i1).vm_bandwidth;
             avail_expec = 1-(tot_predicted_DT/tot_predicted_TNF);
             if avail_expec < user(vm(i1).user_id).downtime_sla
                 sla_downtime_penalty_vector(i2,i3) = (1+sla_downtime_penalty);
             end
         end
     end
 end
 
 % check at least one resource is available
 if sum(sum(sum(pm_availability)))==0
     fprintf(log_file_ID,'@ %d - No resource available to place VM %d of user %d.\n',time,i1,vm(i1).user_id);
     vm(i1).active = false;     % make sure that VM is not activated
     return
 end
 % calculating the cost of vm on available resources
 init_cost = (vm(i1).vm_mips*[pm_types.compute_cost] ...
      + vm(i1).vm_memory*[pm_types.mem_cost] ...
      + vm(i1).image_size*[pm_types.storage_cost]);
      %+ vm(i1).vm_bandwidth*[pm_types.bandwidth_cost]);    % BW cost claculated seperately
 cost = (sla_downtime_penalty_vector).*(init_cost'*ones(1,max([pm_types.pm_counts]))); % this is intermediary cost and customer is not going to be charged with it
  
 combined_pm_availability = sum(pm_availability,3);
 combined_pm_availability = 10000*(~combined_pm_availability)+1;
 
 cost = cost.*combined_pm_availability; % this assigns huge cost to the machines that are not available and effectively removes them from scheduling
 
 [min_cost,min_cost_type_index] = min(min(cost,[],2));
 [min_cost,min_cost_pm_index] = min(cost(min_cost_type_index,:));
 [min_cost,avail_cpu_index] = max(pm_availability(min_cost_type_index,min_cost_pm_index,:));
 
%  vm_assigned = 0;
%  while(vm_assigned==0)
%      [min_cost,min_cost_index] = min(cost);
%      if sum(sum([pm_availability(min_cost_index,:,:)]))==0  % if no resource available for this PM type
%          cost(min_cost_index) = 2*max(cost);                % eliminate it from next iteration
%          continue
%      end
%      vm_assigned = 1;
%  end

 % set the VM cost
 % Note that the cost of extra downtime would be added later.
 vm(i1).net_cost = init_cost(min_cost_type_index);
 % assignment and utilization update
%  [found_index,avail_pm_index,avail_cpu_index] = find(pm_availability(min_cost_type_index,1:pm_types(min_cost_type_index).pm_counts,1:pm_types(min_cost_type_index).cpu_per_pm)>0,1);
%  found_index = min_cost_pm_index;
%  avail_pm_index = mod(found_index,pm_types(min_cost_type_index).pm_counts);
%  if (avail_pm_index==0)
%      avail_pm_index = pm_types(min_cost_type_index).pm_counts;
%  end
%  avail_cpu_index = ceil((found_index - min_cost_pm_index + 1)/pm_types(min_cost_type_index).pm_counts);
 pm_types(min_cost_type_index).mips_util(min_cost_pm_index,avail_cpu_index) = pm_types(min_cost_type_index).mips_util(min_cost_pm_index,avail_cpu_index) + vm(i1).vm_mips;
 pm_types(min_cost_type_index).memory_util(min_cost_pm_index) = pm_types(min_cost_type_index).memory_util(min_cost_pm_index) + vm(i1).vm_memory;
 pm_types(min_cost_type_index).storage_util(min_cost_pm_index) = pm_types(min_cost_type_index).storage_util(min_cost_pm_index) + vm(i1).image_size;
 pm_types(min_cost_type_index).bandwidth_util(min_cost_pm_index) = pm_types(min_cost_type_index).bandwidth_util(min_cost_pm_index) + vm(i1).vm_bandwidth;
 % vm assignment info save
 vm(i1).location = [min_cost_type_index, min_cost_pm_index, avail_cpu_index];
 % save the availability of cheapest resource
 PM_type_avail_summary = [1,zeros(1,length(pm_types)-1)]+sum(sum(pm_availability,3),2)';
 % assignment log
fprintf(log_file_ID,'@ %d - \tAssignment: VM %d of user %d to PM type: %d PM index: %d CPU index: %d.\n',time,i1,vm(i1).user_id,min_cost_type_index,min_cost_pm_index,avail_cpu_index);

