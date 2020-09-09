

# Initialize the simulation setup and filter parameter values
addpath('initialization/');

# Generate states and measurements for all simulation trials.
# ps_initial = generateTracksMeasurements(ps_initial);
setup      = generateMeasurements(setup);
# Produce tracking results for each algorithm and each trial.
output = cell(setup.nTrial,1);


for trial_ix=1:setup.nTrial
    setup.trial_ix = trial_ix;
    output{trial_ix} = run_one_trial(setup,trial_ix);        
end
