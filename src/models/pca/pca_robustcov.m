function [coeff,score,latent]= pca_robustcov(X)
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


[r,c]=size(X);
%co=(1 / (r-1))*(X')*X;
[co,mu,mah,outliers] = robustcov(X);

[coeff,latent]=eig(co);
if nargout>1
latent = diag(latent);
score = (X*coeff);
end
