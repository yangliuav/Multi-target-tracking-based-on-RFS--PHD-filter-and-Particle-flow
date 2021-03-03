function tracking_output = run_one_trial(ps,trial_ix,video,Z_doa)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the interface used to run different filtering algorithms.
%
% Inputs:
% ps: structure with filter and simulation parameters
%
% Output:
% tracking_output: a struct that contains outputs from different filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tracking_output = [];

if ~trial_ix
    trial_ix = ps.trial_ix;
end

path = ['./result/',num2str(trial_ix)];
if exist(path,'dir')==0
   mkdir(path);
   mkdir([path,'/IPF'])
   mkdir([path,'/ZPF']);
   mkdir([path,'/NPF']);
   mkdir([path,'/NPFS']);
   mkdir([path,'/SMC']);
end
switch ps.Ac.example_name
    case 'Acoustic'
        ps.x = ps.inp.x_all{ceil(trial_ix/ps.Ac.setup.nAlg_per_track)};
        y = ps.inp.y_all;
    case 'Visual'  
        ps.x = ps.inp.x_all{ceil(1)};
        y = ps.inp.y_all;
    case 'Real_Data'  
        ps.x = ps.inp.x_all{ceil(1)};
        y = ps.inp.y_all;
end

if ismember('NPF-SMC_PHD',ps.algs)
    ps_new = ps;
    ps_new.pf_type = 'NPF';
    tracking_output.NPFSMC = SMCPHD(ps_new,y,video,Z_doa);
end
if ismember('NPF-SMC_PHD_S',ps.algs)
    ps_new = ps;
    ps_new.pf_type = 'NPFS';
    tracking_output.NPFSMCS = SMCPHD(ps_new,y,video,Z_doa);
end

if ismember('SMC_PHD',ps.algs)
    rng(ps.inp.random_seeds(trial_ix),'twister'); 
    ps_new = ps;
    ps_new.pf_type = 'SMC';
    Init_PATH = './SMCPHD';           % Point the folder where the data are located.
    ps_new.Ac.setup.pf_type = 'None';
    addpath( Init_PATH ); 
    tracking_output.SMC_PHD = SMCPHD(ps_new,y,video,Z_doa);
end

if ismember('ZPF-SMC_PHD',ps.algs)
    ps_new = ps;
    ps_new.pf_type = 'ZPF';
    tracking_output.ZPFSMC = SMCPHD(ps_new,y,video,Z_doa);
end

if ismember('IPF-SMC_PHD',ps.algs)
    ps_new = ps;
    ps_new.pf_type = 'IPF';
    tracking_output.ZPFSMC = SMCPHD(ps_new,y,video,Z_doa);
end



%% plot modify （暂时不知道在何处调用,似乎是在最后调用，最后checking）
dt = datestr(now,'yyyymmddHHMM')
dt = [dt,'_',num2str(trial_ix),'.mat'];
save(dt);
drawresult(tracking_output,ps);
end