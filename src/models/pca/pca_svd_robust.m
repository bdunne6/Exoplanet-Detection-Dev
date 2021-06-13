function [coeff,score,latent,ioutliers]= pca_svd_robust(X,N,M)
% PCA_SVD: perform Principal Component Analysis (pca) using svd method
%     COEFF = pca(X) returns the principal component coefficients for the N
%     by P data matrix X. Rows of X correspond to observations and columns to
%     variables. Each column of COEFF contains coefficients for one principal
%     component. The columns are in descending order in terms of component
%     variance (LATENT).
%
%     [COEFF, SCORE] = pca(X) returns the principal component score, which is
%     the representation of X in the principal component space. Rows of SCORE
%     correspond to observations, columns to components. The centered data
%     can be reconstructed by SCORE*COEFF'.
%
%     [COEFF, SCORE, LATENT] = pca(X) returns the principal component
%     variances, i.e., the eigenvalues of the covariance matrix of X, in
%     LATENT.

ioutliers_cell = [];
Xi1 = X;
for i1 = 1:N
    [coeff,score,latent] = pca_svd(Xi1);
    ioutliers_i1 = find(any(isoutlier(score,'gesd','MaxNumOutliers',M,'ThresholdFactor',0.1),2));
    Xi1(ioutliers_i1,:) = [];
    ioutliers_cell = [ioutliers_cell, {ioutliers_i1}];
end
xind = 1:size(X,1);
for i1 = 1:N
    xind(ioutliers_cell{i1}) = [];
end
ioutliers = ~ismember(1:size(X,1),xind);
score = X*coeff;



