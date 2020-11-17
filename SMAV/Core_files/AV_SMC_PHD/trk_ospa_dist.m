function [dist varargout]= trk_ospa_dist(X,Xlab,Y,Ylab,OSPA)

%B. Vo.  26/08/2007
%Compute Schumacher distance between two finite sets X and Y
%Inputs: X,Y-   matrices of column vectors
%        c  -   cut-off parameter
%        p  -   p-parameter for the metric
%Output: scalar distance between X and Y
%Note: the Euclidean 2-norm is used as the "base" distance on the region

p = OSPA.p;
c = OSPA.c;
l = OSPA.l;

if nargout ~=1 & nargout ~=3
   error('Incorrect number of outputs'); 
end

%Calculate sizes of the input point patterns
n = size(X,2);
m = size(Y,2);

if n==0 & m==0
    dist = 0;
    if nargout == 3
        varargout(1)= {0};
        varargout(2)= {0};
    end
    return;
end

if n==0 | m==0
    dist = (1/max(m,n)*c^p*abs(m-n))^(1/p);
    if nargout == 3
        varargout(1)= {0};
        varargout(2)= {(1/max(m,n)*c^p*abs(m-n))^(1/p)};
    end   
    return;
end


%Calculate cost/weight matrix for pairings - fast method with vectorization
% XX= repmat(X,[1 m]);
% YY= reshape(repmat(Y,[n 1]),[size(Y,1) n*m]);
% D = reshape(sqrt(sum((XX-YY).^2)),[n m]);
% D = min(c,D).^p;

% %Calculate cost/weight matrix for pairings - slow method with for loop
D= zeros(n,m);
for j=1:m
    for i=1:n
        bdist = sum(abs(Y([1 3],j) - X([1 3],i)).^p);  % pos error only
        ldist = OSPA.l^p * not(Xlab(i)==Ylab(j));
        D(i,j)= (bdist + ldist)^(1/p);
    end
end
D= min(c,D).^p;

%Compute optimal assignment and cost using the Hungarian algorithm
[assignment,cost]= Hungarian(D);

% % assignment based on labels
% iass = zeros(n,m);
% for i=1:n
%     ix = find( Xlab(i) == Ylab);
%     if not(isempty(ix))
%         iass(i,ix) = 1;
%     end
% end
% label_error = sum(sum(abs(assignment - iass)));

%Calculate final distance
dist= ( 1/max(m,n)*( c^p*abs(m-n)+ cost ) ) ^(1/p);

%Output components if called for in varargout
if nargout == 3
    varargout(1)= {(1/max(m,n)*cost)^(1/p)};
    varargout(2)= {(1/max(m,n)*c^p*abs(m-n))^(1/p)};
end
    