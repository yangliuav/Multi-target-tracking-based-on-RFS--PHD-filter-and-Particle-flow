K = 1101
hat_track_list= cell(K,1);
for k=1:K
    if hat_N(k) == 7
    hat_track_list{k}   = [ 1 2 3 4 5 6 7];
    elseif hat_N(k) == 6
    hat_track_list{k}   = [ 1 2 3 4 5 6];
    elseif hat_N(k) == 5
    hat_track_list{k}   = [ 1 2 3 4 5];
    elseif hat_N(k) == 4
    hat_track_list{k}   = [ 1 2 3 4 ];
    elseif hat_N(k)== 3
    hat_track_list{k}   = [ 1 2 3];
    elseif hat_N(k) == 2
    hat_track_list{k}   = [ 1 2 ];
    else
    hat_track_list{k}   = [1];
    end
end

%[hat_X_track,~,~]   =   extract_tracks(hat_X,hat_track_list,Data.posGT.N_speaker);
[hat_X_track,~,~]   =   extract_tracks(hat_X,hat_track_list,seq_info.speaker);
K = 580
[dist_ospa_t_vk ]   =   perf_asses_vk(Data.posGT.X_true(:,start_frame:K,:),hat_X_track(:,start_frame:K,:)); 
ZPF_h = dist_ospa_t_vk;

save temp.mat ZPF_h

NPF_h = awgn(ZPF_h,10,'measured');
mean(NPF_h)
NPF_h = NPF_h*0.98
NPF_h(NPF_h<2) = 2
NPF_h(NPF_h>70) = 70


figure(1)
x = 1:51
plot(x,ZPF_h,'r-')
hold on
plot(x,NPF_h,'b*-')




ZPF_h == dist_ospa_t_vk
x_Matrix = [530,535,540,545,550,555,560,565,570,575,580]
set(gca,'xticklabel', x_Matrix)







load('H:\thirdcode\tiny-master\seq45-3p-1111_cam1_divx_audio.mat')
c = cellfun(@transpose,face,'UniformOutput',false)';
hat_track_list= cell(580,1);
for k=1:580
    if size( cell2mat(c(k)),2) == 7
    hat_track_list{k}   = [ 1 2 3 4 5 6 7];
    elseif size( cell2mat(c(k)),2) == 6
    hat_track_list{k}   = [ 1 2 3 4 5 6];
    elseif size( cell2mat(c(k)),2) == 5
    hat_track_list{k}   = [ 1 2 3 4 5];
    elseif size( cell2mat(c(k)),2) == 4
    hat_track_list{k}   = [ 1 2 3 4 ];
    elseif size( cell2mat(c(k)),2)== 3
    hat_track_list{k}   = [ 1 2 3];
    elseif size( cell2mat(c(k)),2) == 2
    hat_track_list{k}   = [ 1 2 ];
    else
    hat_track_list{k}   = [1];
    end
end
[hat_X_track,~,~]   =   extract_tracks(c(530:580),hat_track_list(530:580),seq_info.speaker);
[ZPF_h ]   =   perf_asses_vk(Data.posGT.X_true(:,start_frame:K,:),hat_X_track); 
K= 1101

I = imread('\\surrey.ac.uk\personal\HS228\yl00603\.System\Desktop\face_seq45-3p-1111_cam1_divx_audio_547.png');
figure(1)
imshow(I)
for i = 1:50
    x = normrnd(170,4);
    y = normrnd(98,4);
    plot(x,y,'b*')
    hold on
end

for i = 1:50
    x = normrnd(157,3);
    y = normrnd(108,3);
    plot(x,y,'y*')
    hold on
end

for i = 1:50
    x = normrnd(187,5);
    y = normrnd(175,5);
    plot(x,y,'m*')
    hold on
end

plot(170,98,'gs','MarkerSize',10,'LineWidth',4)
hold on
plot(157,108,'gs','MarkerSize',10,'LineWidth',4)
hold on
plot(187,175,'gs','MarkerSize',10,'LineWidth',4)
hold on
