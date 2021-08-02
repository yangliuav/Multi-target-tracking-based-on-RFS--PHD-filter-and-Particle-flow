function [model] = create_noise(model,t)
%NOISE is going to create noise for each agent
%   each agent creates random variable 
%   based standard normal distribution noise ~ N(0,1)
%   then create noise based on equation (4) from paper
%   inputs: model, timestamp

if t == 1
    model.v{t} = normrnd(0,1,[model.nAgent,1]);
else
    v = model.v{t-1};
    for i = 1:model.nAgent
        v(i) = normrnd(0,abs(v(i)));
    end
    model.v{t} = v;
end

if t == 1
    model.noise{t} = model.v{t};
else
    model.noise{t} = (model.gama^t) * model.v{t} - (model.gama^(t-1)) * model.v{t-1};
end

end

