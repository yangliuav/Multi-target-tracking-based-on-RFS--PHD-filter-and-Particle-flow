function [dist, loce, carde, card_X, card_Y] = perf_asses_vk(trk,est_trk,apar)
% trk - true tracks3
% est_trk - estimated tracks
% VER 2: : new assignment of estimated to true tracks
%

if nargin == 3
    OSPA.l = apar;
else
    OSPA.l = 25;
end


PLOT = 1;


OSPA.p = 2;
OSPA.c = 65;

[a1, K1, num_trk] = size(trk);
[a2, K2, num_etrk] = size(est_trk);

if (a1~= a2) || (K1 ~= K2) 
    error('wrong input');
end

% find the global best assignment of true tracks to estimated tracks
DELTA = 80;
D = zeros(num_trk,num_etrk);
for i=1:num_trk
    t = trk(:,:,i);
    for j=1:num_etrk
        et = est_trk(:,:,j);
        cnt = 0;
        for k=1:K1
            if not(isnan(t(1,k))) || not(isnan(et(1,k)))
                d = sqrt(sum((t(:,k) - et(:,k)).^2));
                if not(isnan(d))
                    D(i,j) = D(i,j) + min(DELTA,d);
                else
                    D(i,j) = D(i,j) + DELTA;
                end
            end
        end
        D(i,j) = D(i,j)/K1;
    end
end



[Matching,Cost] = Hungarian(D);
for i=1:num_trk
    trk_corr(i) = find(Matching(i,:) == 1);
end



for k=1:K1
    X = [];
    Xl = [];
    for i=1:num_trk
 %       if not(isnan(trk(1,k,i)))
        if not(isnan(trk(1,k,i)) | ~sum(trk(1,k,i))  ) % Added by volkan
            X = [X trk(:,k,i)];
            Xl = [Xl i];
        end
    end
    card_X(k) = size(X,2);
    Y = [];
    Yl = [];
    for i=1:num_etrk
    %    if not(isnan(est_trk(1,k,i)))
        if not(isnan(est_trk(1,k,i)) | ~sum(est_trk(1,k,i))) % Added by volkan
            Y = [Y est_trk(:,k,i)];
            ix =find(trk_corr == i);
            if not(isempty(ix))
                Yl = [Yl ix];
            else
                Yl = [Yl 12345];
            end
        end
    end
    card_Y(k) = size(Y,2);
    %
    [dist(k) loce(k) carde(k)] = trk_ospa_dist(X,Xl,Y,Yl,OSPA);
end

