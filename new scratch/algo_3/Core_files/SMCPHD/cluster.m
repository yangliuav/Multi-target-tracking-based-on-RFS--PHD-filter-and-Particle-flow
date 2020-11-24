function x=cluster(data,N)
if N>1
%     [centers, U, obj_fcn] = fcm(data', N);
    [index,centers]= kmeans(data',N,...
                'maxiter',200,'replicates',10,'emptyaction','singleton');
    x=centers'; 
elseif N==1
    x=mean(data,2);
else
    x=[];
end