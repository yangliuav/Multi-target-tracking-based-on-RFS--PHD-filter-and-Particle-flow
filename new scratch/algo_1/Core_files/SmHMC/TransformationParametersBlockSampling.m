function [MatrixTransformation]=TransformationParametersBlockSampling(NbDim,IndexBlock,IndexVector,Sizeblock);%,CurrentMean,CurrentCov,CurrentSkewness)
% Funtion required when random permutation of the elements of the state to sample

Current=IndexVector((IndexBlock-1)* Sizeblock+1:IndexBlock* Sizeblock);
C=IndexVector;
C((IndexBlock-1)* Sizeblock+1:IndexBlock* Sizeblock)=[];
Index=[Current C];
A=zeros(NbDim);A(Index+[0:(size(Index,2)-1)]*NbDim)=1;
MatrixTransformation=A';


