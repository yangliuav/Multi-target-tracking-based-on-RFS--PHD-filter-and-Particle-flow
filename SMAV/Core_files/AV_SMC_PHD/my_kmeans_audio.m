function [ x_out, hat_X]= my_kmeans_audio( X, n_clust,W,doa_number,cam_number,n_clust_prev,sequence )
% This function clusters the particles.
% @ August 2016, University of Surrey

% =========================================================================
% Input:

% X             -   particle set.
% n_clust       -   estimated number of speaker.
% W             -   weight of the particles.
% doa_number    -   number of DOA azimuth angle.
% cam_number    -   it indicates camera number: 1, 2 or 3.
% n_clust_prev  -   previous cluster number. 
% sequence      -   name of the sequence.
% =========================================================================
% Output:
% x_out         -   new particle set.
% hat_X         -   estimated speaker position.
% =========================================================================


% We need to size of X for "my_resample"
size_x  = size(X,2); %  size of the X may change, but we need original size

if n_clust == doa_number
    if n_clust == n_clust_prev % It is the perfect case,

        max_clust       =   n_clust;
        distance_check  =   1;  % No need to check distance
    elseif n_clust > n_clust_prev       
      
        max_clust       =   n_clust;
        if n_clust >1
            distance_check  =   1;  % Need to check distance    
        else
            distance_check  =   0;  % No need to check distance
        end
    elseif n_clust < n_clust_prev
        max_clust       =   n_clust_prev;
         distance_check  =   1;  % need to check distance
    end
    
elseif n_clust > doa_number
    if n_clust == n_clust_prev
    % n_clust is true since there is no doa even speaker is in the scene.
        max_clust       =   n_clust;
        % it is necessary in the case of occlusion case
        %distance_check  =  0;  % No need to check distance
        distance_check  =   1;  % need to check distance
    elseif n_clust > n_clust_prev
    % In that case, n_clust is wrong because wrong estimation
    % Distance check
    
    % There is no DOA data, like seq24-1 frame 541
        if doa_number >0
            max_clust       =  doa_number;
            if doa_number >1
                distance_check  =   1;  % Need to check distance    
            else
                distance_check  =   0;  % No need to check distance
            end
        else
            max_clust       =  n_clust;
            distance_check  =   1;
        end

    else
         max_clust       =   n_clust_prev;
         distance_check  =   1;  % need to check distance
    end
    
elseif n_clust < doa_number
    % New speaker enters but could not detect by the phd filter.
    % Divide into doa_number cluster
    % Distance check
    
    % Or, there is a occlusion case
    max_clust       =  doa_number;
    distance_check  =   1;  % Need to check distance 
    
end

if max_clust ==1
% We have to use my_resample here, because in the main function resampling is done based on hat_N_soft
% and sometimes hat_N_soft is larger than it is. Therefore we need reduce
% back to X what it is supposed to be
    
    idx         =   my_resample(W ,round(size_x/n_clust));
    x_out       =   X(:,idx) ;
    hat_X       =   X(:,idx)*W(idx)/sum(W(idx))  ;
    hat_X(1,:)  =   round(hat_X(1,:));
    hat_X(3,:)  =   round(hat_X(3,:));
    
else
    x_out   =   [];
    P_temp  =   [];
    X_temp  =   [];
    W_temp  =   [];
    size_x  = size(X,2); %  size of the X may change, but we need original size

    
    dist_threshold= dist_threshold_check(sequence,cam_number);


    repeat      =   1;
    while repeat
        repeat  =   0;
        x_out   =   [];  
        hat_X	=   [];
        P       =   [ 1 0 0 0 0 ; 0 0 1 0 0 ]*X; % get only positions

        T       =   clusterdata(P','maxclust',max_clust);  
        T_idx   =   0; % reset T_idx
        for i=1:max(T)
            T_idx(i)    =   size(find(T==i),1);
        end
        T_idx_sort  = sort(T_idx,'descend');

        % Normally, we expect one outlier group, but sometimes outlier group may
        % more than one. For  that case we need to check and fix.
        if length(T_idx_sort)>1
            %while T_idx_sort(end-1)<5 
            counter = 0;
            while T_idx_sort(end)<3  % ????   

                for i=1:length(T_idx_sort)-1
                    P_temp  =   [P_temp P(:,find(T== find(T_idx == T_idx_sort(i),1))  )];
                    X_temp  =   [X_temp X(:,find(T== find(T_idx == T_idx_sort(i),1))  )];
                    W_temp  =   [W_temp; W(find(T== find(T_idx == T_idx_sort(i),1))  )];
                end
                P   =   P_temp;
                X   =   X_temp;
                W   =   W_temp;
                P_temp  = []; 
                X_temp  = []; 
                W_temp	= [];

                T       =   clusterdata(P','maxclust',max_clust); 
                T_idx   =   0; % reset T_idx
                for i=1:max(T)
                    T_idx(i)    =   size(find(T==i),1);
                end
                T_idx_sort  =	sort(T_idx,'descend');
                counter= counter+ 1;
                if counter ==3  % To prevent infinite loop
                     T_idx_sort = T_idx_sort(1:end-1);
                     break;
                end

            end
        end

        % In some cases, n_clust may be less than used to be
        % in that situation, to prevent mis-calculation, i modified that line with
        % size(T_idx_sort), If n_clust is true, outlier will be removed with if
        % command
        % for i=1:n_clust 
        for i=1:length(T_idx_sort)

            index_T         =   find(T_idx == T_idx_sort(i),1);
            T_idx(index_T)  =   0; % Reset if it is used
            id_cluster{i}   =   find(T == index_T);
            idx         =   my_resample(W(id_cluster{i}) ,round(size_x/n_clust));
            x_out       =   [x_out X(:,id_cluster{i}(idx)) ];            
            hat_X       =   [hat_X  (X(:,id_cluster{i}(idx))*(W(idx))/sum(W(idx)))  ];
            hat_X(1,:)  =   round(hat_X(1,:));
            hat_X(3,:)  =   round(hat_X(3,:));
        end

         if distance_check
            P       =   [ 1 0 0 0 0 ; 0 0 1 0 0 ]*hat_X;
            dist    =   squareform(pdist(P'));

    % Find the points close to each other and take the average        
            if min(  dist(dist>0)  ) < dist_threshold
                repeat      =   1;
                max_clust   =   max_clust-1;
            end

         end
    end
end
            