function seed_number= seed_selection_av(sequence, cam_number)
% This function returns one of the seed number that has been used in the
% experiments. All the experiments are repeated 10 times, so 10 differenct
% seed numbers are used which are generated randomly.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% sequence      -   name of the sequence.
% cam_number    -   it indicates camera number: 1, 2 or 3.
% =========================================================================
% Output:
% seed_number   -   seed number to repeat the experiment.
% =========================================================================
    
if strcmp(sequence, 'seq24-2p-0111')
        
    if cam_number == 1
        seeds           =   [ 48  95 77 171  39 5 158 69 17 190];
        seed_number     =   seeds(1);
        
    elseif cam_number == 2
        seeds           =   [];
        seed_number     =   seeds(1); 
        
    elseif cam_number == 3
        seeds           =   [ 48  95 77 171  39 5 158 69 17 190];
        seed_number     =   seeds(1); 
        
    end
    
elseif strcmp(sequence, 'seq25-2p-0111')
    
    if cam_number == 1
        seeds           =   [];
        seed_number     =   seeds(1);
        
    elseif cam_number == 2
        seeds           =   [];
        seed_number     =   seeds(1);
        
    elseif cam_number == 3
        seeds           =   [];
        seed_number     =   seeds(1);
        
    end
    
elseif strcmp(sequence, 'seq30-2p-1101')
    
    if cam_number == 1
        seeds           =   [];
        seed_number     =   seeds(1);
        
    elseif cam_number == 2
        seeds           =   [];
        seed_number     =   seeds(1); 
        
    elseif cam_number == 3
        seeds           =   [];
        seed_number     =   seeds(1);  
        
    end
        
elseif strcmp(sequence, 'seq45-3p-1111')
    
    if cam_number == 1
        seeds           =   [ 48  95 77 171  39 5 158 69 17 190];
        seed_number     =   seeds(1);
        
    elseif cam_number == 2
        seeds           =   [];
        seed_number     =   seeds(1);        
        
    elseif cam_number == 3
        seeds           =   [ 48  95 77 171  39 5 158 69 17 190];
        seed_number     =   seeds(1);    
        
    end    

end