function [AD,R] = my_average_bin(D,N,dim)
% MY_AVERAGE_BIN Average successive data ("binning") along dimension dim.
% 	[AD,R] = MY_AVERAGE_BIN(D,N) computes the average of groups of N samples
%	of matrix data D and returns them as AD. A group of samples consists in
%	N successive samples from the same column/row (dim=1/2) vector. Accordingly, one value
%	of AD replaces N values of D. AVERAGE_BIN acts on each column/row (dim=1/2) of the matrix.
%
%	R is an optional output 1x2 vector returning as R(1) the number of rows/columns (dim=1/2) of AD,
%	and as R(2) the number of unused rows/columns (dim=1/2) of D, because not large number enough
%	in quantity to compute one more averaged row/column (dim=1/2) (R(2) < N).
%
% Description and original code:
% Observatoire de Neuchatel, Renaud Matthey, 15.10.2001.
% New code:
% Meteoswiss, Yann Poltera, 25.07.2014

if(nargin==2)
    dim = 1;
end

if(N==1)
    AD = D;R = [size(D,dim) 0]; return;
end

R = [fix(size(D,dim)/N) rem(size(D,dim),N)];

if(dim==1)
    AD = NaN(R(1),size(D,mod(dim,2)+1));
    for i=1:R(1)
       AD(i,:) = nanmean(D((i-1)*N+1:i*N,:),dim);
    end
end
if(dim==2)
    AD = NaN(size(D,mod(dim,2)+1),R(1));
    for i=1:R(1)
       AD(:,i) = nanmean(D(:,(i-1)*N+1:i*N),dim);
    end    
end

end