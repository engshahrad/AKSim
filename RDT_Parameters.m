%% General Parameters

draw_fig = 1;
save_fig = 1;
save_data = 1;

time = 0;                       % time origin

second = 1;
minute = 60;
hour = 3600;
day = 86400;                    % 24*60*60
week = 604800;                  % 7*24*60*60
month = 2592000;                % 30*day

sim_step = 5*minute;            % simulation time step in seconds
sim_duration = 2*month;         % total duration of simulation

measurement_period = 1*month;   % the availability measurement period
round_to_downtime_dic = 0;      % round required downtimes to fixed available options

avail_aware_scheduler = 1;      % consider expected downtime in scheduling
deliberate_downtimes = 1;       % deliberately make users experience downtime
sla_downtime_penalty = 3;       % used for optimum pm selection
relative_penalty = 1;           % 1->relative downtime penalty used to optimize
sla_downtime_rel_penalty = 100;
sla_downtime_cost_penalty = 0.1;% (percent) used to calc extra credit cost to provider
average_prof_margin = 0.2;      % average provider profit margin
end_to_center_margin_imbalance = 0; % self descriptive :)

% Users
user_count = 50;                % Number of virtual machines

% PMs
pm_types_counts = [1,2,5];
pm_types_afr = [0.1813,0.2835,0.6321];

% Downtime
downtime_dic = [.99901 .99999];
user_avail_dist = 'Uniform';        % Uniform/Normal/Bimodal

% Benign VM Migration
benign_migration = 1;               % 0: disable 1: enable
benign_migration_period = 1*hour;	% migrating VMs that already received very good service to cheaper resources
benign_migration_frac = 0.1;   		% the top fraction of over-served VMs to be migrated

% Unexpected Failure DT Model Parameters
% average in seconds: UFDT_gam_a*UFDT_gam_b
UFDT_gam_a = 1;
UFDT_gam_b = 10;

% Catastrophic Event
cat_event = 0;                      % 0: No catastrophic event
cat_event_time = [3.2*month];       % Catastrophic even occurance time
cat_event_duration = [5*hour];      % Duration of the catastrophic event
