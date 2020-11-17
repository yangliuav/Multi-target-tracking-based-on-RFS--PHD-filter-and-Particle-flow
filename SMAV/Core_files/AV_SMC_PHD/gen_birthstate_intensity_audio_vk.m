 function X= gen_birthstate_intensity_audio_vk(model,num_par,new_doa,old_doa,cam_number,Data,hat_X,FrameNumber,sequence)
% This function is called if the number of DOA is larger than previous
% estimated number of speaker.Born particles will be distributed even in 
% the occlusion case.
% @ August 2016, University of Surrey

% =========================================================================
% Input:
% model         -   variables used in the phd filtering.
% num_par       -   no. of particles for birth speakers.
% new_doa       -   current DOA. 
% old_doa       -   DOA from previous time step
% cam_number    -   it indicates camera number: 1, 2 or 3.
% Data          -   contains GT, azimuth, timing, camera calibration.
%               -   information.
% hat_X         -   position estimation from previous time step.
% FrameNumber   -   number of current frame.
% sequence      -   name of the sequence.
% =========================================================================
% Output:
% X             -   particle set with recently generated particles.
% =========================================================================
 
 
% hat_X is the previos position estimation

X                       =   [];
doa_to_use              =   []; % maybe new born doa is in the occlusion. So we may not distribute anything.


if isempty(hat_X) 
    % No speaker is detected in previos frame
    doa_to_use = new_doa;

elseif size(hat_X,2)==1
    % One speaker is detected in previos frame
    
    if length(old_doa) == size(hat_X,2)
    % find new born particles using old_doa
        doa_to_use = find_doa_with_old_doa(new_doa,old_doa);
    else
    %  find new born particles using hat_X
        doa_to_use = find_doa_with_old_X(new_doa,hat_X,cam_number,Data,FrameNumber);
    end   

elseif size(hat_X,2)==2
    
    if length(old_doa) == size(hat_X,2)
    % find new born particles using old_doa
        doa_to_use = find_doa_with_old_doa(new_doa,old_doa);
    else
    %  find new born particles using hat_X
        doa_to_use = find_doa_with_old_X(new_doa,hat_X,cam_number,Data,FrameNumber);
    end
    
end


% Distributing "born particles", around DOA line uniformly
for l=1:length(doa_to_use)

    [Q5,Q6,~]          =   doa_endpoints(cam_number,doa_to_use(l),Data,FrameNumber);
    [line_x,line_y,~]   =   improfile(1,[ Q5(1) Q6(1)], [Q5(2) Q6(2)]);   % Get the coordinates lay on the audio line
    line_x              =   round(line_x);
    line_y              =   round(line_y);
    slope_line          =  (line_y(end)-line_y(1))/(line_x(end)-line_x(1)); % Update slope after rounding
    m3                  =   atan(slope_line);
    m3                  =   mod(m3,2*pi); 

    if m3> -0.01 && m3<(pi/2+0.01) % if it is 4 th zone
        rotate_angle    =   m3-pi/2;
    elseif m3> (3*pi/2) && m3<(2*pi)
        rotate_angle    =   pi/2 -(2*pi-m3);
    end

    % find unique coordinates  
    line_cord= [line_x line_y];
    [line_cord, bandwith_of_points]=check_line_cord(line_cord,line_x,line_y,doa_to_use(l),cam_number,sequence);

    if isempty(line_cord)
%         display('empty line')
        continue  % We need to "continue" instead of "break"
        % because it is possible to draw more than one line.
        % If we use "break" and it executes for the first doa, then it wont
        % draw second doa
    end

    height_of_distribution      =   max(pdist(line_cord));
    init_points                 =   round([bandwith_of_points*rand(1,num_par); height_of_distribution*rand(1,num_par)]'); % initial points
    center_initial_points       =   mean(init_points); % find the center
    originalized_points(:,1)    =   init_points(:,1) -center_initial_points(1);
    originalized_points(:,2)    =   init_points(:,2) -center_initial_points(2);

    for k=1:size(originalized_points,1)
        c(k,1)  =   norm(originalized_points(k,:)); %#ok<AGROW>
        z       =   complex(originalized_points(k,1),originalized_points(k,2));
        c(k,2)  =   angle(z)+rotate_angle; %#ok<AGROW> % angle(z) is angle in radian
        new_coord   = c(k,1)*exp(1i*c(k,2));
        c(k,1)  =   round(real(new_coord));%#ok<AGROW>
        c(k,2)  =   round(imag(new_coord));%#ok<AGROW>
    end
    center_shift    =   mean(line_cord);
    temp_x          =   [];
    temp_x(1,:)     =   c(:,1)+center_shift(1);
    temp_x(2,:)     =   model.bar_B(2,2,1)*rand(1,num_par);
    temp_x(3,:)     =   c(:,2)+center_shift(2) ;
    temp_x(4,:)     =   model.bar_B(4,4,1)*rand(1,num_par);
    temp_x(5,:)     =   model.bar_B(5,5,1)*rand(1,num_par);

    X           =   [ X temp_x]; %#ok<AGROW>
    X(1,:)      =   round(cap(X(1,:), 1, model.posn_interval(1,2)));
    X(3,:)      =   round(cap(X(3,:), 1, model.posn_interval(3,2)));

end

 end  % End function
 
 
 function doa_to_use = find_doa_with_old_doa(new_doa,old_doa)
    ind     = mod(find ( abs((repmat(new_doa,[1 length(old_doa)]) - repmat(old_doa,[1 length(new_doa)])))==   max(abs(repmat(new_doa,[1 length(old_doa)]) - repmat(old_doa,[1 length(new_doa)])))     ),max(length(new_doa),length(old_doa)));
    
    if ind>0 % sometimes, ind becomes zero
        doa_to_use = new_doa(ind);
    else
        doa_to_use = new_doa(end);
    end
 end
 
 function doa_to_use = find_doa_with_old_X(new_doa,hat_X,cam_number,Data,FrameNumber)
     % We need to find which DOA has just born.
    P   =   hat_X([1,3],:);  % Get the position of estimated speakers in k-1
    doa_to_use = new_doa;
        for j=1:size(P,2)
            for i=1:length(new_doa)
                [Q5,Q6,m3]  =   doa_endpoints(cam_number,new_doa(i),Data,FrameNumber);
                Q(1,:)      =   [Q5' Q6' m3]; 
                Q1          =   Q(1,1:2)';
                Q2          =   Q(1,3:4)'; 
                dist(i,j)   =   abs(det([Q2-Q1,P(:,j)-Q1]))/norm(Q2-Q1); %#ok<AGROW>
            end
            % find the DOA belongs to estimated point and delete from
            % doa_maybe_use
            doa_to_use(find( doa_to_use== new_doa( find(dist(:,j) == min(dist(:,j)),1) )   ))   =   [];   %#ok<FNDSB>
        end
 
 end
