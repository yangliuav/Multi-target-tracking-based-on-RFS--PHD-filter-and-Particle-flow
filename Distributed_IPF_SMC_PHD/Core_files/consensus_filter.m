 function xp = consensus_filter(xp,model)
% This function implements proposed average consensus filter algorithm by 
% The implementation code has been re-writed by Peipei Wu
% @ June 2021, University of Surrey
% 
% Details about the algorithm can be found in the paper:
% Inputs:
% xp: input state
%
% Outputs:
% xp: updated state

%%
model.initX = xp;
for t = 1:100%model.iter_range
    model = create_noise(model, t);
    model = consensus_update(model,t);
end
xp = model.X{t}
end

