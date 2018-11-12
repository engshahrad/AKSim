%% Bulding model used for unexpected failure downtime

% Note: In an event of failure, VMs experience some downtime. This downtime
% is a function of the VM image size as well as a random time.

UFDT_pd = makedist('Gamma');
UFDT_pd.a = 1;
UFDT_pd.b = 1;

% tic
% for i=1:10000
%     UFDT = random(UFDT_pd);
% end
% toc
UFDT_gam_b = 10;
UFTD = zeros(1,10000);
tic
for i=1:10000
    UFDT(i)=gamrnd(1,UFDT_gam_b);
end
toc