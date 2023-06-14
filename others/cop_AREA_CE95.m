function [saxes,hypervolume] = cop_AREA_CE95(data)
    [n, p] = size(data); % 2-D array dimensions
    covar = cov(data); % covariance matrix of data
    [U, S, V] = svd(covar); % singular value decomposition
    f95 = finv(.95,p,n-p)*(n-1)*p*(n+1)/n/(n-p); % F 95 percent point function
    saxes = sqrt(diag(S)*f95); % semi-axes lengths
    hypervolume = pi^(p/2)/gamma(p/2+1)*prod(saxes); %for p=2, gamma(p/2+1)=1
end