function [vgset] = SpawnAndBirthParticle(setup,vgset, FrameNumber)
numParticle =  size(vgset,2);
sigma0 = setup.Ac.initparams.sigma0;
area   = setup.Ac.initparams.survRegion;
dim = 4;
m0 = [area(3),area(4),sigma0(3),sigma0(4)]';
for i = (numParticle+1):(numParticle+setup.nParticle)
    vgset(i).xp = m0.*rand(4,1);            % particle position
    vgset(i).PP = zeros(4,4);               % particle prediction
    vgset(i).PU = blkdiag(100,100,1,1);     % particle update
    vgset(i).M  = vgset(i).xp;
    vgset(i).xp_m = vgset(i).xp;
    vgset(i).logW = 0;
    vgset(i).w  = 1/50;
    vgset(i).PD = 1;
    vgset(i).B = 0;
end

Q_name = ['Q' num2str(FrameNumber) '.mat'];
if isfile(Q_name)
%% Move the particles
% calculate min distances with line label
    for i=1:size(vgset,2)  % For each particle

        P   =   vgset([1,3],i); % i th particle coordinate
        for j=1:length(Z)
            Q1          =   Q(j,1:2)';
            Q2          =   Q(j,3:4)';    
            dist_temp   =   abs(det([Q2-Q1,P-Q1]))/norm(Q2-Q1);    % Calculate  shortest distance to line
            if j>1 && (dist_temp < dist_line(1,i))             
                dist_line(1,i)  =   dist_temp;  % min distance %#ok<AGROW>
                dist_line(2,i)  =   j;           % label%#ok<AGROW>
            elseif j==1
                dist_line(1,i)  =   dist_temp;%#ok<AGROW>
                dist_line(2,i)  =   1;%#ok<AGROW>
            end
        end
    end

    dist_threshold  =   100; %!!!!!!!
    idx             =   find(dist_line(1,:)>dist_threshold);
    dist_line(1,idx)=   0;  %#ok<FNDSB> % Cancel the particles whose distance is more than threshold
    dist_mov        =   dist_line(1,:)*0.2;

    BD_cof =1; %!!!!!!

    for i=1:size(vgset,2)

        if  dist_line(1,i)>0
            Q1  =   Q(dist_line(2,i),1:2)';
            Q2  =   Q(dist_line(2,i),3:4)';  
            m   =   Q(dist_line(2,i),5);

            % There are two angles perpendicular to line
            delta1  =   atand(m)+90+180;              % Angle of perpendicular line to Given line
            delta2  =   atand(m)-90+180;              % Angle of perpendicular line to Given line

            temp_P1(1,1)        =   vgset(1,i) + dist_mov(i)*cosd(delta1)*BD_cof;     % Spread particles vgset position
            temp_P1(2,1)        =   vgset(3,i) + dist_mov(i)*sind(delta1)*BD_cof;     % Spread particles y position 
            check_dist_delta1   =   abs(det([Q2-Q1,temp_P1-Q1]))/norm(Q2-Q1);        % Calculate distance to line


            % we need to check which delta is correct                  
            if check_dist_delta1 < dist_line(1,i)
                vgset(1,i)  =   temp_P1(1,1);
                vgset(3,i)  =   temp_P1(2,1);
            else 
    %             vgset(1,i)  =   vgset(1,i) +dist_mov(i)*cosd(delta2)*BD_cof;   % Spread particles vgset position
    %             vgset(3,i)  =   vgset(3,i) + dist_mov(i)*sind(delta2)*BD_cof;  % Spread particles y position  
                vgset(1,i)  =   vgset(1,i) + 0.5*dist_mov(i)*cosd(delta2)*BD_cof;   % Spread particles vgset position
                if 235-vgset(1,i)>5
                     vgset(1,i)  =   vgset(1,i) + 0.5*(235-vgset(1,i));
                end
                vgset(3,i)  =   vgset(3,i) + 0.5*dist_mov(i)*sind(delta2)*BD_cof
                if 84-vgset(3,i)>5
                    vgset(3,i)  =   vgset(3,i)+ 0.5*(84-vgset(3,i));  % Spread particles y position   
                end
            end
        end
    end

    vgset(1,:)  =   round(cap(vgset(1,:), 1, width));
    vgset(3,:)  =   round(cap(vgset(3,:), 1, height));    

    % apply concerntrate_on_doa here
    % load Q{Frame Number}
    % paste
end
end