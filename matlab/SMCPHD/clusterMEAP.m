function xout=clusterMEAP(data,w,lik,N)
    L = size(data,2);          
    [Dtemp,wSub]=sort(-sum(lik));
    [Zmtx, indx] = max(lik,[],2);
    xout=zeros(2,min(N,L));
    wsubsum = zeros(1,min(N,L));
    NJz = zeros(1,6);
    for j=1:6   
        Jz = find(indx==wSub(j));
        NJz(:,j) = size(Jz,1); 
%         Jz = lik(:,wSub(j))>0.01;
        wsubsum(:,j)=sum(w(Jz));
        wsub=w(Jz)'/wsubsum(:,j);
        xout(:,j)=data([1,2],Jz)*wsub;
    end

    for i = 1:size(xout,2)-1
        for j = i+1:size(xout,2)
            if j<=size(xout,2)
                minu = bsxfun(@minus,xout(:,i),xout(:,j));
                m = minu(1)^2 + minu(2)^2;
                m = m^(1/2);
                if m < 3
                    if wsubsum(:,i) +wsubsum(:,j) <1 && NJz(:,i)+NJz(:,j) < size(w,2)/N
                        xout(:,i) = wsubsum(:,i)*xout(:,i) + wsubsum(:,j)*xout(:,j);
                        wsubsum(:,i) = wsubsum(:,i) + wsubsum(:,j);
                        xout(:,j)=[];
                        wsubsum(:,j)=[];
                        NJz(:,j) = [];
                        j = j -1;
                    end
                end
            end
        end
    end
    xout = xout(:,1:N);
end

      