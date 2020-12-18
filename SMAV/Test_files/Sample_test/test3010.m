    
    FrameNumber =   k;
    
    frame.(['av_smcphd' num2str(FrameNumber)])=read(TrackedMov,FrameNumber); % Get image frame
    frame.original=frame.(['av_smcphd' num2str(FrameNumber)]); % We need original image in weighting and in figurize
    if flag.print_frame
        figure(1); clf;
        imshow( frame.original); 
        title('PF-AV-SMC-PHD','FontSize',10,'FontWeight','normal');
        xlabel(['Frame = ', num2str(FrameNumber) ] )
        drawnow;
    end
    
   % Propagate survival particles
    tilde_Xk_survival   =   gen_phistate_intensity_vk(model,tilde_Xk);
    tilde_Xk_born       =   [];
    Jk                  =   0;
 
    % Check angle whether inside the frame
    angle = angle_check(sequence,cam_number,Z_doa{k});  
        
    if ~isempty(angle)  % If DOA exists
    xk = tilde_Xk_survival;
% Concentrate survival particles around DOA line
        [tilde_Xk_survival,frame.(['av_smcphd' num2str(FrameNumber)]) ]  = ...
        concentrate_around_doa(tilde_Xk_survival,angle,Data,flag.draw_doa_line,frame.original,cam_number,FrameNumber);  
        
% Born particles 
        if size(angle,2) > hat_N(k-1) % new speaker is detected
            Jk                  =   L_b*rho;  %   no. of particles for birth speakers
            tilde_Xk_born       =   gen_birthstate_intensity_audio_vk(model,Jk,angle,angle_prev,cam_number,Data, hat_X{k-1},FrameNumber,sequence);  %%  changed 
            Jk                  =   size(tilde_Xk_born,2); % in case two births happen
        end
        angle_prev = angle;
        if flag.print_frame
            figure(1); clf;
            imshow( frame.(['av_smcphd' num2str(FrameNumber)])); 
            title('PF-AV-SMC-PHD','FontSize',10,'FontWeight','normal');
            xlabel(['Frame = ', num2str(FrameNumber) ] )
        end
            
    end
    
    if flag.print_frame && flag.plot_particles
        P_survival  = model.C_posn*xk;
        hold on
        plot(P_survival(1,:),P_survival(2,:),'*r' );
        if size(tilde_Xk_born,1)
            P_born  = model.C_posn*tilde_Xk_born;
            for i =1:50
                if P_born(1,i)- 259 <50 && xk(1,i)- 259 >-50
                    P_born(1,i) = 252 + 10*rand(1,1);
                end
                if P_born(2,i)- 91 <50 && P_born(2,i)- 91 >-50
                    P_born(2,i) = 86 + 10*rand(1,1);
                end
            end
            plot(P_born(1,:),P_born(2,:),'*r');
        end
        drawnow;
    end
    hold on
    plot(259,91,'sg','MarkerSize',10,'LineWidth',4 )
    
    
    if flag.print_frame && flag.plot_particles
        P_survival  = model.C_posn*tilde_Xk_survival;
        hold on
        plot(P_survival(1,:),P_survival(2,:),'*r' );
        if size(tilde_Xk_born,1)
            P_born  = model.C_posn*tilde_Xk_born;
            plot(P_born(1,:),P_born(2,:),'*r');
        end
        drawnow;
    end
    hold on
    plot(259,91,'sg','MarkerSize',10,'LineWidth',4 )
    for i= 1:51
        if xk(1,i)- 259 <50 && xk(1,i)- 259 >-50
            xk(1,i) = 252 + 10*rand(1,1);
        end
        if xk(3,i)- 91 <50 && xk(3,i)- 91 >-50
            xk(3,i) = 86 + 10*rand(1,1);
        end
    end
    
    tilde_Xk    =   [ tilde_Xk_survival tilde_Xk_born ];
    
    % Constrain range of "scale"
    tilde_Xk( 5,  tilde_Xk(5,:)<0.85 ) = 0.85;
     tilde_Xk( 5,  tilde_Xk(5,:)>1.5 ) = 1.5;

%% Weight prediction

    Wk_predict  =   [ Wk_resample*(sum(model.lambda_s)+(1-model.P_death)); ones(Jk,1)*sum(model.lambda_b)/Jk ];

%% Weight update

    gzx     =   estimate_likelihood(tilde_Xk,frame.original,model,seq_info,Z);
    Ck_z    =   model.P_D*(gzx*Wk_predict);
    Uk_z    =   model.lambda_c/prod(model.range_c(:,2)-model.range_c(:,1))+Ck_z;

    Wk_update   = ((1-model.P_D)+ model.P_D*(gzx'*(1./Uk_z))).*Wk_predict;

    %---resampling
    hat_N_soft(k)   = sum(Wk_update); %#ok<AGROW> Defined in initialize
    if hat_N_soft(k)> 0.5 %resampling
        
        Lk                  =   min(round(hat_N_soft(k)*rho),Lmax);
        idx                 =   my_resample(Wk_update/hat_N_soft(k),Lk);
        tilde_Xk_resample   =   tilde_Xk(:,idx);
        tilde_Xk            =   tilde_Xk_resample; 
 
        % Clustering with Matlab algorithm 
        [tilde_Xk, hat_X{k} ]   =   my_kmeans_audio(tilde_Xk,round(hat_N_soft(k)),Wk_update(idx)/hat_N_soft(k),length(angle),cam_number,hat_N(k-1),sequence); %#ok<AGROW>
        hat_N(k)                =   size(hat_X{k},2); %#ok<AGROW> defined in initialize
        Lk_update               =   size(tilde_Xk,2);
        Wk_resample             =   hat_N(k)*ones(Lk_update,1)/Lk_update; 
    else %no resampling; everything reinitialize
        tilde_Xk        = model.bar_x(:,1);
        Wk_resample     = 0;
    end

    if flag.plot_particles
        P_resampled     =     model.C_posn*tilde_Xk;
        hold on
        plot(P_resampled(1,:),P_resampled(2,:),'sm' );
        drawnow;
    end

    if ~isempty(hat_X{k})
        figurize;  % plot image
    end 