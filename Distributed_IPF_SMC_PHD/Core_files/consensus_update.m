function model = consensus_update(model,t)
%UPDATE is going to updata local estimate state of each agent
%   based on equation (13) from paper
%   Detailed explanation goes here
%   inputs: model, timestamp 
if t == 1 % extract last moment state
    x = model.initX;
else
    x = model.X{t-1};
end
xp = x + model.noise{t}; % current observation

model.X{t} = model.W * xp; % update state (replace A by W)

y = {};
for i = 1:model.nAgent % update info set of each agent one by one
    y{i} = model.C{i} * model.X{t};
end
model.Y{t} = y;

%  create average vector
model.x_ave{t} = (ones(1,model.nAgent)* model.X{t} * ones(model.nAgent, 1))/ model.nAgent;

%   create true error vector
model.Z{t} = model.X{t} - model.x_ave{t};
end

