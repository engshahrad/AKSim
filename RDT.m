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


clear all

%% General Parameters
% time: s / storage: MB
% Figure drawing on -> 1

RDT_Parameters

% log file
log_file_ID = fopen('./temp_res/simulation.log','w');
fprintf(log_file_ID,'***** Cloud Simulator *****\n\n\n');
fprintf(log_file_ID,'Simulation started at: %s\n\n',datestr(now));
fprintf(log_file_ID,'Simul. duration: %d month(s)\nSimul. Step: %d minute(s)\n',sim_duration/month,sim_step/minute);
fprintf(log_file_ID,'Availability Measurement Period: %d month(s)\n',measurement_period/month);
fprintf(log_file_ID,'Benign Migration Period: %d day(s)\n',benign_migration_period/day);
fprintf(log_file_ID,'Benign Migration Fraction: %d percent\n',100*benign_migration_frac);
fprintf(log_file_ID,'Round to Downtime Dic: %d\n',round_to_downtime_dic);

%tot_provider_cost = zeros(1,sim_duration/sim_step);
tot_provider_cost = zeros(1,ceil(sim_duration/measurement_period));
provider_profit = zeros(1,ceil(sim_duration/measurement_period)); % monthly
pm_utilization = zeros(length(pm_types_counts),sim_duration/sim_step);  % stores PM utilizations during time (active VM counts)
cpu_utilization = zeros(length(pm_types_counts),sim_duration/sim_step); % stores average CPU utilization for pm_type

%% Users

fprintf(log_file_ID,'User Count: %d\n',user_count);
user_app_groups = struct();     % name/popularity/vm_count_trend/vm_mips/image_size/vm_bandwidth
user = struct();                % vm_count/type/vm_mips/vm_memory/image_size/user_id
vm = struct();
mean_mips_per_core = 12e3;
mean_data_in_cost = 0.01;       % per GB
mean_data_out_cost = 0.05;      % per GB (average of the egress traffic cost)

% Different User Groups
user_app_groups(1).name = 'Web Hosting Services';
user_app_groups(1).popularity = 1;
user_app_groups(1).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(1).vm_mips = mean_mips_per_core;
user_app_groups(1).vm_memory = 2*2^10;          % timesGB (2^10=1GB=1024MB)
user_app_groups(1).image_size = 10*2^10;        % timesGB (2^10=1GB=1024MB)
user_app_groups(1).vm_bandwidth = 1*2^10;       % Average BW (in Mbps)
user_app_groups(1).vm_monthly_traffic_in = 10*2^10; % TimesTera (in GB)
user_app_groups(1).vm_monthly_traffic_out = 10*2^10;
user_app_groups(1).vm_lifetime_average = 1*month;
user_app_groups(1).vm_react_mean = 1*hour;

user_app_groups(2).name = 'Analytics';
user_app_groups(2).popularity = 1;
user_app_groups(2).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(2).vm_mips = 4*mean_mips_per_core;
user_app_groups(2).vm_memory = 8*2^10;      % timesGB
user_app_groups(2).image_size = 20*2^10;    % timesGB
user_app_groups(2).vm_bandwidth = .5*2^10;
user_app_groups(2).vm_monthly_traffic_in = 1*2^10;
user_app_groups(2).vm_monthly_traffic_out = 1*2^10;
user_app_groups(2).vm_lifetime_average = 5*day;
user_app_groups(2).vm_react_mean = 1*day;

user_app_groups(3).name = 'Enterprise Data Warehouse ';
user_app_groups(3).popularity = 1;
user_app_groups(3).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(3).vm_mips = mean_mips_per_core;
user_app_groups(3).vm_memory = 1*2^10;      % timesGB
user_app_groups(3).image_size = 30*2^10;    % timesGB
user_app_groups(3).vm_bandwidth = .25*2^10;
user_app_groups(3).vm_monthly_traffic_in = 10*2^10;
user_app_groups(3).vm_monthly_traffic_out = 10*2^10;
user_app_groups(3).vm_lifetime_average = 2*month;
user_app_groups(3).vm_react_mean = 1*week;

user_app_groups(4).name = 'CRM Applications'; % Customer Relationship Management
user_app_groups(4).popularity = 1;
user_app_groups(4).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(4).vm_mips = mean_mips_per_core;
user_app_groups(4).vm_memory = 2*2^10;      % timesGB
user_app_groups(4).image_size = 10*2^10;    % timesGB
user_app_groups(4).vm_bandwidth = .25*2^10;
user_app_groups(4).vm_monthly_traffic_in = 10*2^10;
user_app_groups(4).vm_monthly_traffic_out = 10*2^10;
user_app_groups(4).vm_lifetime_average = 1*month;
user_app_groups(4).vm_react_mean = 1*week;

user_app_groups(5).name = 'Enterprise Email Service';
user_app_groups(5).popularity = 1;
user_app_groups(5).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(5).vm_mips = 2*mean_mips_per_core;
user_app_groups(5).vm_memory = 4*2^10;      % timesGB
user_app_groups(5).image_size = 40*2^10;    % timesGB
user_app_groups(5).vm_bandwidth = .5*2^10;
user_app_groups(5).vm_monthly_traffic_in = 10*2^10;
user_app_groups(5).vm_monthly_traffic_out = 10*2^10;
user_app_groups(5).vm_lifetime_average = 3*month;
user_app_groups(5).vm_react_mean = 1*day;

user_app_groups(6).name = 'HCM Applications'; % Human Capital Management
user_app_groups(6).popularity = 1;
user_app_groups(6).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(6).vm_mips = mean_mips_per_core;
user_app_groups(6).vm_memory = 1*2^10;      % timesGB
user_app_groups(6).image_size = 10*2^10;    % timesGB
user_app_groups(6).vm_bandwidth = .25*2^10;
user_app_groups(6).vm_monthly_traffic_in = 1*2^10;
user_app_groups(6).vm_monthly_traffic_out = 1*2^10;
user_app_groups(6).vm_lifetime_average = 1*month;
user_app_groups(6).vm_react_mean = 1*week;

user_app_groups(7).name = 'Software Driven Network';
user_app_groups(7).popularity = 1;
user_app_groups(7).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(7).vm_mips = 2*mean_mips_per_core;
user_app_groups(7).vm_memory = 2*2^10;      % timesGB
user_app_groups(7).image_size = 10*2^10;    % timesGB
user_app_groups(7).vm_bandwidth = 1*2^10;
user_app_groups(7).vm_monthly_traffic_in = 20*2^10;
user_app_groups(7).vm_monthly_traffic_out = 20*2^10;
user_app_groups(7).vm_lifetime_average = 2*week;
user_app_groups(7).vm_react_mean = 1*day;

user_app_groups(8).name = 'Procurement and Auditing Applications';
user_app_groups(8).popularity = 1;
user_app_groups(8).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(8).vm_mips = mean_mips_per_core;
user_app_groups(8).vm_memory = 1*2^10;      % timesGB
user_app_groups(8).image_size = 5*2^10;     % timesGB
user_app_groups(8).vm_bandwidth = .25*2^10;
user_app_groups(8).vm_monthly_traffic_in = 1*2^10;
user_app_groups(8).vm_monthly_traffic_out = 1*2^10;
user_app_groups(8).vm_lifetime_average = 2*week;
user_app_groups(8).vm_react_mean = 2*week;

user_app_groups(9).name = 'Others';
user_app_groups(9).popularity = 1;
user_app_groups(9).vm_count_trend = [0.8,0.15,0.05];
user_app_groups(9).vm_mips = mean_mips_per_core;
user_app_groups(9).vm_memory = 2*2^10;      % timesGB
user_app_groups(9).image_size = 5*2^10;     % timesGB
user_app_groups(9).vm_bandwidth = .25*2^10;
user_app_groups(9).vm_monthly_traffic_in = 1*2^10;
user_app_groups(9).vm_monthly_traffic_out = 1*2^10;
user_app_groups(9).vm_lifetime_average = 1*day;
user_app_groups(9).vm_react_mean = 1*week;

popularity_dist = [user_app_groups.popularity]';
popularity_dist = popularity_dist/sum(popularity_dist); % normalization
% popularity_pd = fitdist(popularity_dist,'Normal');
% dist_test = random(popularity_pd,[1,200]);
% hist(dist_test)

% VM downtime requirement distribution
% 1. Fixed
downtime_dic_index = randi([1 4], 1, user_count);
% 2. Distributed
RDT_Avail_SLA
downtime_dic_mean = mean(sla_downtime);
downtime_dic_mean_v = downtime_dic_mean*ones(1,user_count);
% price_ratio = sqrt((1-downtime_dic_mean_v)./(1-sla_downtime));
price_ratio = 1 + end_to_center_margin_imbalance*(sla_downtime-downtime_dic_mean)/(downtime_dic(end)-downtime_dic_mean);
price_ratio_correction = 1/mean(price_ratio);
prev_tot_provider_cost = 0;                 % stores total provider cost for the past period

downtime_fulfillment = zeros(user_count,ceil(time/measurement_period)); % keeps the periodic user DT fulfillments  
dec_var_index = (user_count*2)*ones(user_count,1);                      % used in RDT_VM_Migration_Rank

% Random User Generation
tot_vm_count = 0;
for i=1:user_count
    % User Type
    r = rand;
    user(i).type = sum(r >= cumsum([0, popularity_dist']));
    % VM count
    r = rand;
    user(i).vm_count = sum(r >= cumsum([0, user_app_groups(user(i).type).vm_count_trend]));
    % VM
    user(i).vm_mips = user_app_groups(user(i).type).vm_mips*ones(1,user(i).vm_count);
    user(i).vm_memory = user_app_groups(user(i).type).vm_memory*ones(1,user(i).vm_count);
    user(i).image_size = user_app_groups(user(i).type).image_size*ones(1,user(i).vm_count);
    user(i).vm_bandwidth = user_app_groups(user(i).type).vm_bandwidth*ones(1,user(i).vm_count);
    user(i).vm_monthly_traffic_in = user_app_groups(user(i).type).vm_monthly_traffic_in*ones(1,user(i).vm_count);
    user(i).vm_monthly_traffic_out = user_app_groups(user(i).type).vm_monthly_traffic_out*ones(1,user(i).vm_count);
    user(i).user_id = 0;
    user(i).tot_runtime = zeros(1,ceil(sim_duration/measurement_period));   % keeps the runtime of a period
    user(i).tot_downtime = zeros(1,ceil(sim_duration/measurement_period));  % keeps the downtime of a period
%     user(i).downtime_sla = downtime_dic(downtime_dic_index(i));
    user(i).downtime_sla = sla_downtime(i);
    % round to fixed numbers if required
    if round_to_downtime_dic==1
        %dic_comparison = user(i).downtime_sla<downtime_dic;
        %user(i).downtime_sla = downtime_dic( length(dic_comparison) - sum(dic_comparison) + 1 );
        user(i).downtime_sla = downtime_dic_mean;
        user(i).avail_price_ratio = 1;
    else
        user(i).avail_price_ratio = price_ratio_correction*price_ratio(i);
    end
    user(i).vm_reactivation = 0;
    user(i).net_cost = 0;
    user(i).period_price = zeros(1,ceil(sim_duration/measurement_period));
    % user.net_cost: overall
    % vm.net_cost: per unit time
    % 
    for j=1:user(i).vm_count
        tot_vm_count = tot_vm_count+1;
        if tot_vm_count==1
            vm = user(i);
        else
            vm = [vm,user(i)];
        end
        vm(tot_vm_count).vm_mips = user(i).vm_mips(j);
        vm(tot_vm_count).vm_memory = user(i).vm_memory(j);
        vm(tot_vm_count).image_size = user(i).image_size(j);
        vm(tot_vm_count).vm_bandwidth = user(i).vm_bandwidth(j);
        vm(tot_vm_count).user_id = i;
        vm(tot_vm_count).vm_monthly_traffic_in = user(i).vm_monthly_traffic_in;
        vm(tot_vm_count).vm_monthly_traffic_out = user(i).vm_monthly_traffic_out;
    end
end

% Generating reactivation models for existing user types
RDT_VM_Reactivation_Model

% VM lifetime modeling
vm_lifetime_average = 1*week;
lasting_factor = 500;
% vm_lifetimes = gamrnd(sqrt(vm_lifetime_average)/lasting_factor,sqrt(vm_lifetime_average)*lasting_factor,1,tot_vm_count);
                                                                                                                                                                                                                                                                                                                                                                                                                                       
% add extra features to vm structure
for i=1:tot_vm_count
    vm(i).init_time = 0;                % absolute time
    vm(i).pause_time = 0;
    vm(i).pause_period = 0;
    vm_lifetime_dist_fac = sqrt(user_app_groups(vm(i).type).vm_lifetime_average);
    vm(i).lifetime = gamrnd(vm_lifetime_dist_fac/lasting_factor,vm_lifetime_dist_fac*lasting_factor,1);   % initial duration
    vm(i).vm_reactivation = random(VM_react_pd(vm(i).type),1);
    vm(i).active = true;
    vm(i).pause = false;
end
% hist([vm.lifetime],30)

% tot_vm_count = sum([user.vm_count]);
tot_vm_mips = sum([user.vm_mips]);
tot_vm_memory = sum([user.vm_memory]);
tot_image_size = sum([user.image_size]);
tot_vm_bandwidth = sum([user.vm_bandwidth]);

% User Log Gen
disp('User generation summary:');
user_log = struct('User_Application_Groups', length(user_app_groups) ...
                 ,'User_Count', user_count ...
                 ,'Tot_VM_Count', tot_vm_count ...
                 ,'Tot_VM_MIPS', tot_vm_mips ...
                 ,'Tot_VM_Memory_G', tot_vm_memory/2^10 ...
                 ,'Tot_VM_IMG_Size_T', tot_image_size/2^20 ...
                 ,'Tot_BW', tot_vm_bandwidth);
disp( user_log )

%% Physical Machines
% PM Types
pm_types = struct();

% AFR-to-MTBF Table
% 0.9817 - 3 month
% 0.8647 - 6 month
% 0.6321 - 1 year
% 0.3935 - 2 years
% 0.2835 - 3 years
% 0.2212 - 4 years
% 0.1813 - 5 years

% Storages (prices from Amazon EBS)
storage_magnetic.cost = 0.05/(1024*month);
storage_magnetic.IOPS_per_Vol = 100;
storage_GP.cost = 0.1/(1024*month);         % good for majority of users
storage_GP.IOPS_per_Vol = 3000;
storage_PIOPS.cost = 0.125/(1024*month);
storage_PIOPS.IOPS_per_Vol = 4000;

% Assumptions
% 1. Each PM has similar processors on it

pm_types(1).pm_counts = pm_types_counts(1);             % number of PMs of this type
pm_types(1).cpu_per_pm = 4;
pm_types(1).cpu = 'Intel E7-x870';                      % processor family
pm_types(1).cpu_freq = 2.4e9;
pm_types(1).cpu_mips = 96.90e3;                         % per CPU
pm_types(1).cores_per_cpu = 10;                         % number of cores per machine
pm_types(1).memory_per_pm = 80*2^10;                    % timesGB
pm_types(1).storage_per_pm = 1*2^20;                    % timesTB
pm_types(1).bandwidth_per_pm = 10*2^10;                 % timesGB (2^10=1GB=1024MB)
pm_types(1).afr = pm_types_afr(1);                      % Annualized Failure Rate
pm_types(1).mtbf = (-8760/log(1-pm_types(1).afr))*hour; % seconds
pm_types(1).arch = 'x86';
pm_types(1).os = 'Linux';                               % operating system
pm_types(1).vmm = 'Xen';
pm_types(1).time_zone = -4.0;                           % time zone (NY)
pm_types(1).compute_cost = 1.5*7e-06/mean_mips_per_core;% processing cost
pm_types(1).mem_cost = 1.5*3.5779e-09;                  % memory cost per MB (calculated from EC2 prices)
pm_types(1).storage_cost = storage_PIOPS.cost;          % per MB
pm_types(1).bandwidth_cost = 1e-8;
pm_types(1).mips_util = zeros(pm_types(1).pm_counts,pm_types(1).cpu_per_pm);     % utilization matrix
pm_types(1).memory_util = zeros(1,pm_types(1).pm_counts);
pm_types(1).storage_util = zeros(1,pm_types(1).pm_counts);
pm_types(1).bandwidth_util = zeros(1,pm_types(1).pm_counts);
pm_types(1).init_time = zeros(1,pm_types(1).pm_counts);
pm_types(1).tbf = zeros(1,pm_types(1).pm_counts);
pm_types(1).status = ones(1,pm_types(1).pm_counts);

pm_types(2).pm_counts = pm_types_counts(2);
pm_types(2).cpu_per_pm = 4;
pm_types(2).cpu = 'Intel 5690';
pm_types(2).cpu_freq = 3.46e9;
pm_types(2).cpu_mips = 83.04e3;             % per CPU
pm_types(2).cores_per_cpu = 6;
pm_types(2).memory_per_pm = 64*2^10;        % timesGB
pm_types(2).storage_per_pm = 3*2^20;        % timesTB
pm_types(2).bandwidth_per_pm = 10*2^10;     % timesGB (2^10=1GB=1024MB)
pm_types(2).afr = pm_types_afr(2);                   % Annualized Failure Rate
pm_types(2).mtbf = (-8760/log(1-pm_types(2).afr))*hour;
pm_types(2).arch = 'x86';
pm_types(2).os = 'Linux';
pm_types(2).vmm = 'Xen';
pm_types(2).time_zone = -4.0;               % NY
pm_types(2).compute_cost = 1.2*7e-06/mean_mips_per_core;
pm_types(2).mem_cost = 1.2*3.5779e-09;
pm_types(2).storage_cost = storage_GP.cost;
pm_types(2).bandwidth_cost = 1e-8;
pm_types(2).mips_util = zeros(pm_types(2).pm_counts,pm_types(2).cpu_per_pm);
pm_types(2).memory_util = zeros(1,pm_types(2).pm_counts);
pm_types(2).storage_util = zeros(1,pm_types(2).pm_counts);
pm_types(2).bandwidth_util = zeros(1,pm_types(2).pm_counts);
pm_types(2).init_time = zeros(1,pm_types(2).pm_counts);
pm_types(2).tbf = zeros(1,pm_types(2).pm_counts);
pm_types(2).status = ones(1,pm_types(2).pm_counts);

pm_types(3).pm_counts = pm_types_counts(3);
pm_types(3).cpu_per_pm = 4;
pm_types(3).cpu = 'Intel 7560';
pm_types(3).cpu_freq = 2.266e9;
pm_types(3).cpu_mips = 75.51e3;         % per CPU
pm_types(3).cores_per_cpu = 8;
pm_types(3).memory_per_pm = 40*2^10;    % timesGB
pm_types(3).storage_per_pm = 1*2^20;    % timesTB
pm_types(3).bandwidth_per_pm = 10*2^10; % timesGB (2^10=1GB=1024MB)
pm_types(3).afr = pm_types_afr(3);                 % Annualized Failure Rate
pm_types(3).mtbf = (-8760/log(1-pm_types(3).afr))*hour;
pm_types(3).arch = 'x86';
pm_types(3).os = 'Linux';
pm_types(3).vmm = 'Xen';
pm_types(3).time_zone = -4.0;   % NY
pm_types(3).compute_cost = 7e-06/mean_mips_per_core;
pm_types(3).mem_cost = 3.5779e-09;
pm_types(3).storage_cost = storage_magnetic.cost;
pm_types(3).bandwidth_cost = 1e-8;
pm_types(3).mips_util = zeros(pm_types(3).pm_counts,pm_types(3).cpu_per_pm);
pm_types(3).memory_util = zeros(1,pm_types(3).pm_counts);
pm_types(3).storage_util = zeros(1,pm_types(3).pm_counts);
pm_types(3).bandwidth_util = zeros(1,pm_types(3).pm_counts);
pm_types(3).init_time = zeros(1,pm_types(3).pm_counts);
pm_types(3).tbf = zeros(1,pm_types(3).pm_counts);
pm_types(3).status = ones(1,pm_types(3).pm_counts);

cheapest_PM_type = 3;

% Generating failure models for existing PM types
RDT_PM_MTBF_Model

% Assigning initial TBF to PMs
for i=1:length(pm_types)
    for j=1:pm_types(i).pm_counts
        pm_types(i).tbf(j) = random(PM_mtbf_pd(i),1);
    end
end

% Add timing shifts for the initial TBF values
% (this is necessary to model machines that didn't start all together)
for i=1:length(pm_types)
    pm_types(i).tbf = (pm_types(i).tbf).*rand(1,pm_types(i).pm_counts);
end

% Calculating Total Physical Asset
tot_pm_count = sum([pm_types.pm_counts]);
fprintf(log_file_ID,'Tot. Server Count: %d\n',tot_pm_count);
tot_core = sum([pm_types.pm_counts].*[pm_types.cpu_per_pm].*[pm_types.cores_per_cpu]);
tot_mips = sum([pm_types.pm_counts].*[pm_types.cpu_per_pm].*[pm_types.cpu_mips]);
tot_memory = sum([pm_types.pm_counts].*[pm_types.memory_per_pm]);
tot_storage = sum([pm_types.pm_counts].*[pm_types.storage_per_pm]);
tot_bandwidth = sum([pm_types.pm_counts].*[pm_types.bandwidth_per_pm]);

% PM Log Gen
disp('PM generation summary:');
pm_log = struct('PM_Types', length(pm_types) ...
               ,'PM_Count', tot_pm_count ...
               ,'PM_Cores', tot_core ...
               ,'PM_MIPS', tot_mips ...
               ,'PM_Memory_G', tot_memory/2^10 ...
               ,'PM_Storage_T', tot_storage/2^20 ...
               ,'PM_Bandwidth', tot_bandwidth);
disp( pm_log )

% Write the pm_types summary to the log file
for i=1:length(pm_types)
    fprintf(log_file_ID,'PM Type %d: Count=%d AFR=%d\n',i,pm_types(i).pm_counts,pm_types(i).afr);    
end

%% Initial VM Placement
tic
for i1=1:tot_vm_count
    check_downtime_sla = 0;
    RDT_IVMP
end
disp('Initial VM Placement Log:');
toc

RDT_DrawAvailUtil

%% Runtime Simulation
% all time values in seconds
tic

ready_to_migrate = 0;           % a flag to show when migration of overserved VMs is possible
users_cost_this_round = zeros(user_count,ceil(sim_duration/measurement_period));
avail_price_record = [0,0,0,0,0,0];   % keeps the price for asked availability (User ID/Period/Req. Aval/Del. Avail/Net Cost/Init Cost)
a_0 = 0.9*(downtime_dic(end)-downtime_dic(1)) + downtime_dic(1);
s = (downtime_dic(end)-downtime_dic(1))/(a_0-downtime_dic(1));

while(time < sim_duration)
    time = time + sim_step;                             % advance simulation time
    period = ceil(time/measurement_period);             % index showing which measurement period
    time_to_end_of_period = period*measurement_period - time; % time left to end of period
 
    % Periodic cost update
    if mod(time,measurement_period)==0
        % loop over all users
        user_availability = ones(1,user_count);
        user_network_cost = ones(1,user_count);
        tot_period_price = 0;
        for i=1:user_count
            user_availability(i) = (user(i).tot_runtime(period) - user(i).tot_downtime(period))/user(i).tot_runtime(period);
            user_network_cost(i) = (user(i).tot_runtime(period)/month)*(user(i).vm_monthly_traffic_in(1)*mean_data_in_cost + ...
                                                                        user(i).vm_monthly_traffic_out(1)*mean_data_out_cost);
            users_cost_this_round(i,period) = (users_cost_this_round(i,period) + user_network_cost(i))*(user(i).tot_runtime(period)-sum([vm([vm.user_id]==i).pause_time]))/user(i).tot_runtime(period);
            user(i).period_price(period) = users_cost_this_round(i,period)*(1+average_prof_margin*user(i).avail_price_ratio);
            tot_period_price = tot_period_price + user(i).period_price(period);
            if user_availability(i)<user(i).downtime_sla
                user(i).net_cost = user(i).net_cost + users_cost_this_round(i,period) + sla_downtime_cost_penalty*user(i).period_price(period);
                avail_price_record = [avail_price_record; i period user(i).downtime_sla user_availability(i) (users_cost_this_round(i,period) + sla_downtime_cost_penalty*user(i).period_price(period)) users_cost_this_round(i,period)];
                fprintf(log_file_ID,'@ %d - \tUser %d is given back credit due to not meeting the SLA. (Req:%d Del:%d).\n',time,i,user(i).downtime_sla,user_availability(i));
            else
                user(i).net_cost = user(i).net_cost + users_cost_this_round(i,period);
                avail_price_record = [avail_price_record; i period user(i).downtime_sla user_availability(i) users_cost_this_round(i,period) users_cost_this_round(i,period)];
            end
        end
        % update total provider cost and period profir
        tot_provider_cost(period) = sum([user.net_cost]);
        provider_profit(period) = tot_period_price - ( tot_provider_cost(period)-prev_tot_provider_cost );
        prev_tot_provider_cost = tot_provider_cost(period);
    end
    
    % Check for catastrophic event
    if cat_event==1
        % check if the time is in the window of the incident
        cat_condition_index = (cat_event_duration > (time*ones(1,length(cat_event_time)) - cat_event_time)) & (time > cat_event_time);
        if sum(cat_condition_index)
            % loop over all VMs
            for i=1:tot_vm_count
                % update the total time and downtime if the VM was supposed to be working
                if (vm(i).active == true)
                    user(vm(i).user_id).tot_runtime(period) = user(vm(i).user_id).tot_runtime(period) + cat_event_duration(cat_condition_index);
                    user(vm(i).user_id).tot_downtime(period) = user(vm(i).user_id).tot_downtime(period) + cat_event_duration(cat_condition_index);
                end
            end
            fprintf(log_file_ID,'@ %d - \tCatastrophic error across the DC. The whole DC will experience DT of %d(hours).\n',time,cat_event_duration(cat_condition_index)/hour);
            time = time + cat_event_duration(cat_condition_index) - sim_step;
            continue                    % skip the rest the simulation iter
        end
    end
    
    active_vm_count = sum([vm.active]);
    % loop over all PMs
    for i=1:length(pm_types)
        % update CPU utilization 
        % (this is basically for the previous time_step)
        cpu_utilization(i,time/sim_step) = mean(sum(pm_types(i).mips_util,2)/(pm_types(i).cpu_per_pm*pm_types(i).cpu_mips));
        % normalizing the cpu_util by considering unavailable PMs
        cpu_utilization(i,time/sim_step) = cpu_utilization(i,time/sim_step)*pm_types(i).pm_counts/sum(pm_types(i).status);
        
        for j=1:pm_types(i).pm_counts
            % reactivate down PMs
            if (pm_types(i).status(j)==0)
                pm_types(i).status(j) = 1;
                pm_types(i).init_time(j) = time;
                pm_types(i).tbf(j) = random(PM_mtbf_pd(i),1);
            end
            % check for PM failure if machine is running
            if ((time - pm_types(i).init_time(j)) > pm_types(i).tbf(j)) && (pm_types(i).status(j)==1)
                fprintf(log_file_ID,'@ %d - \tFailure in machine# %d of PM type %d.\n',time,j,i);
                pm_types(i).status(j) = 0;
            end
        end
    end
    
    % loop over all VM instances
    for i=1:tot_vm_count
        if (vm(i).active == true)   % active VM
            pm_utilization(vm(i).location(1),time/sim_step) = pm_utilization(vm(i).location(1),time/sim_step) + 1;
            pm_type = vm(i).location(1);
            pm_index = vm(i).location(2);
            cpu_index = vm(i).location(3);
            % update user uptime
            user(vm(i).user_id).tot_runtime(period) = user(vm(i).user_id).tot_runtime(period) + sim_step;
            % update cost
            users_cost_this_round(vm(i).user_id,period) = users_cost_this_round(vm(i).user_id,period) + vm(i).net_cost*sim_step;
            % instance expiration check
            if ((time - (vm(i).init_time+vm(i).pause_time)) > vm(i).lifetime)&&(vm(i).pause==false)
                vm(i).active = false;
                % release corresponding resources
                pm_types(pm_type).mips_util(pm_index, cpu_index) = pm_types(pm_type).mips_util(pm_index, cpu_index) - vm(i).vm_mips;
                pm_types(pm_type).memory_util(pm_index) = pm_types(pm_type).memory_util(pm_index) - vm(i).vm_memory;
                pm_types(pm_type).storage_util(pm_index) = pm_types(pm_type).storage_util(pm_index) - vm(i).image_size;
                pm_types(pm_type).bandwidth_util(pm_index) = pm_types(pm_type).bandwidth_util(pm_index) - vm(i).vm_bandwidth;
                fprintf(log_file_ID,'@ %d - \tVM deactivation & resource releasing: VM %d -> PM type: %d / PM index: %d / CPU index: %d.\n',time,i,pm_type,pm_index,cpu_index);
                continue    % skip the rest
            end
            % machine availability check
            if pm_types(pm_type).status(pm_index) ~= 1
                vm(i).active = false;   % deactivate
                % Update the user downtime
                % Note that since the whole vm migration is typically less
                % that the simulation time step, it is correct to just
                % calculate the downtime and reschedule the vm right here.
                % Also note that factor of 8 is for Byte/bit ratio.
                % In an event of failure, VMs experience some downtime,
                % which is a function of the VM image size as well as a
                % random value determined by a gamma distribution.
                user(vm(i).user_id).tot_downtime(period) = user(vm(i).user_id).tot_downtime(period) + 8*vm(i).vm_memory/vm(i).vm_bandwidth + gamrnd(UFDT_gam_a,UFDT_gam_b);
                % release corresponding resources
                pm_types(pm_type).mips_util(pm_index, cpu_index) = pm_types(pm_type).mips_util(pm_index, cpu_index) - vm(i).vm_mips;
                pm_types(pm_type).memory_util(pm_index) = pm_types(pm_type).memory_util(pm_index) - vm(i).vm_memory;
                pm_types(pm_type).storage_util(pm_index) = pm_types(pm_type).storage_util(pm_index) - vm(i).image_size;
                pm_types(pm_type).bandwidth_util(pm_index) = pm_types(pm_type).bandwidth_util(pm_index) - vm(i).vm_bandwidth;
                fprintf(log_file_ID,'@ %d - \tDue to failure, VM %d migrated from PM type: %d / PM index: %d / CPU index: %d.\n',time,i,pm_type,pm_index,cpu_index);
                % VM migration
                for i1=i:i
                    check_downtime_sla = avail_aware_scheduler;
                    RDT_IVMP
                    % if the assignment is not successful it jumps out of loop
                    vm(i).active = true;
                    fprintf(log_file_ID,'@ %d - \tMigration & reassignment successful.\n',time);
                end
            end
            % check for Benign VM Migration (BMV) flag
            if (ready_to_migrate==1)&&(vm(i).pause==false)&&(vm(i).active==true)
                if (find(dec_var_index==vm(i).user_id,1) > (1-benign_migration_frac)*(user_count))&&(pm_type~=cheapest_PM_type)
                    if sum(PM_type_avail_summary((pm_type+1):end))~=0   % if there is cheaper resource available
                        vm(i).active = false;   % deactivate
                        % icrease the downtime
                        user(vm(i).user_id).tot_downtime(period) = user(vm(i).user_id).tot_downtime(period) + 8*vm(i).vm_memory/vm(i).vm_bandwidth;
                        % release corresponding resources
                        pm_types(pm_type).mips_util(pm_index, cpu_index) = pm_types(pm_type).mips_util(pm_index, cpu_index) - vm(i).vm_mips;
                        pm_types(pm_type).memory_util(pm_index) = pm_types(pm_type).memory_util(pm_index) - vm(i).vm_memory;
                        pm_types(pm_type).storage_util(pm_index) = pm_types(pm_type).storage_util(pm_index) - vm(i).image_size;
                        pm_types(pm_type).bandwidth_util(pm_index) = pm_types(pm_type).bandwidth_util(pm_index) - vm(i).vm_bandwidth;
                        fprintf(log_file_ID,'@ %d - \tDue to DTf, VM %d migrated from PM type: %d / PM index: %d / CPU index: %d.\n',time,i,pm_type,pm_index,cpu_index);
                        % VM migration
                        for i1=i:i
                            check_downtime_sla = avail_aware_scheduler;
                            RDT_IVMP
                            % if the assignment is not successful it jumps out of
                            % loop
                            vm(i).active = true;
                            fprintf(log_file_ID,'@ %d - \tMigration & reassignment successful.\n',time);
                        end
                    end
                end
            end
            % check for dileberate downtime
            if deliberate_downtimes==1
                if vm(i).pause==false
                    user_vm_count = user(vm(i).user_id).vm_count;
                    vm_max_affordabel_DT_in_period = ((user(vm(i).user_id).tot_runtime(period)+user_vm_count*time_to_end_of_period)*(1-user(vm(i).user_id).downtime_sla) - user(vm(i).user_id).tot_downtime(period))/user_vm_count; 
                    vm_time_to_wake = 8*vm(i).vm_memory/vm(i).vm_bandwidth;
                    if (time_to_end_of_period-sim_step>=0)&&((time_to_end_of_period-sim_step)<vm_max_affordabel_DT_in_period)&&(vm_time_to_wake<0.95*vm_max_affordabel_DT_in_period)
                        vm(i).pause = true;     % pause the VM
                        vm(i).pause_time = vm(i).pause_time + vm_max_affordabel_DT_in_period;    % apply the total pause here
                        vm(i).pause_period = period;
                        g2 = s*((1-vm_max_affordabel_DT_in_period) - downtime_dic(1)) + downtime_dic(1);
                        DDT_safe_gaurd = 0.05*(1-g2);
                        user(vm(i).user_id).tot_downtime(period) = user(vm(i).user_id).tot_downtime(period) + vm_max_affordabel_DT_in_period - DDT_safe_gaurd;   % do it here conservatively
                        % no CPU and network usage when paused, but vm
                        % stills consumes memory and storage
                        pm_types(pm_type).mips_util(pm_index, cpu_index) = pm_types(pm_type).mips_util(pm_index, cpu_index) - vm(i).vm_mips;
                        pm_types(pm_type).bandwidth_util(pm_index) = pm_types(pm_type).bandwidth_util(pm_index) - vm(i).vm_bandwidth;
                        fprintf(log_file_ID,'@ %d - \tDeliberate DT, VM %d paused for %d on PM type: %d / PM index: %d / CPU index: %d.\n',time,i,vm_max_affordabel_DT_in_period,pm_type,pm_index,cpu_index);
                    end
                else    % if the VM is already paused
                    if period>vm(i).pause_period
                        vm(i).pause = false;    % unpause the VM
                        fprintf(log_file_ID,'@ %d - \tVM %d unpaused.\n',time,i);
                        pm_types(pm_type).mips_util(pm_index, cpu_index) = pm_types(pm_type).mips_util(pm_index, cpu_index) + vm(i).vm_mips;
                        pm_types(pm_type).bandwidth_util(pm_index) = pm_types(pm_type).bandwidth_util(pm_index) + vm(i).vm_bandwidth;
                        
                        %% free up memory and storage on the previous machine
                        %pm_types(pm_type).memory_util(pm_index) = pm_types(pm_type).memory_util(pm_index) - vm(i).vm_memory;
                        %pm_types(pm_type).storage_util(pm_index) = pm_types(pm_type).storage_util(pm_index) - vm(i).image_size;
                        % user(vm(i).user_id).tot_downtime(period) = user(vm(i).user_id).tot_downtime(period) + 8*vm(i).vm_memory/vm(i).vm_bandwidth;
                        % vm(i).active = false;
                        % for i1=i:i
                        %    check_downtime_sla = avail_aware_scheduler;
                        %    RDT_IVMP
                        %    % if the assignment is not successful it jumps out of loop
                        %    vm(i).active = true;
                        %    fprintf(log_file_ID,'@ %d - \tMigration & reassignment successful.\n',time);
                        %end
                    end
                end
            end
        else                        % inactive VM
            % inactive instance reactivation
            if(time > vm(i).vm_reactivation + (vm(i).init_time + vm(i).lifetime) )
                for i1=i:i
                    check_downtime_sla = avail_aware_scheduler;
                    RDT_IVMP
                    fprintf(log_file_ID,'@ %d - \tReactivation & reassignment successful.\n',time);
                end
                vm(i).active = true;
                vm(i).init_time = time;
                vm(i).pause_time = 0;   % clear the pause time history
                vm(i).vm_reactivation = random(VM_react_pd(vm(i).type),1);
                % new lifetime
                vm_lifetime_dist_fac = sqrt(user_app_groups(vm(i).type).vm_lifetime_average);
                vm(i).lifetime = gamrnd(vm_lifetime_dist_fac/lasting_factor,vm_lifetime_dist_fac*lasting_factor,1);
            end
        end
    end
    
    % Determine if benign migration should to be performed in the next iter
    ready_to_migrate = 0;
    if benign_migration==1
        if mod(time,benign_migration_period)==0
            RDT_VM_Migration_Rank
            ready_to_migrate = 1;
        end
    end
end
disp('Runtime Simulation Log:');
pm_log = struct('Active_VMs', sum([vm.active]) ...
               ,'Of_Total', tot_vm_count ...
               ,'Sim_Duration_sec', sim_duration ...
               ,'Sim_Duration_day', sim_duration/day);
disp( pm_log )
toc

RDT_DrawAvailUtil

%% User Availability Calc
user_availability = ones(user_count,ceil(time/measurement_period));
for i=1:user_count
    for j=1:ceil(time/measurement_period)
        user_availability(i,j) = (user(i).tot_runtime(j) - user(i).tot_downtime(j))/user(i).tot_runtime(j);
    end 
end
RDT_DrawUserAvail
avail_price_record = avail_price_record(2:end,:);   % remove the first row which has no information
RDT_SaveData    % save the required data
RDT_DrawAvailPrice

%%
% close the report log file
fprintf(log_file_ID,'\nSimulation finished at: %s\n',datestr(now));
fclose(log_file_ID);

%% Figure Drawing
if draw_fig == 1
    subplot_x = 2;
    subplot_y = 1;
    figure
    subplot(subplot_y,subplot_x,1)
    hist([user.type],length(user_app_groups))
    title('User Group Distribution');
    
    subplot(subplot_y,subplot_x,2)
    hist([user.vm_count],length(user_app_groups))
    title('User VM Count Distribution');
end
