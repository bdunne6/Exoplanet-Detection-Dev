classdef pca_model
    %PCA_MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X
        Xc
        Xm
        N
        coeff
        scores
        latent
        mean_centered
    end
    
    methods
        function obj = pca_model(x,mean_center,normalize)
            if nargin > 0
                obj.mean_centered = mean_center;
                
                obj.X = x;
                obj.Xm = mean(x);
                obj.Xc = x;
                if mean_center
                    obj.Xc= obj.Xc-repmat(obj.Xm,size(x,1),1);
                end
                [obj.coeff, obj.scores, obj.latent] = pca_svd(obj.Xc);
            end
        end
        
        function [scores_out] = project(obj,x)
            %             scores_out = obj.coeff*x;
            scores_out = x(:)'*obj.coeff;
        end
        function [x_out] = reconstruct(obj,scores_in)
            scores = zeros(size(obj.coeff,2),1);
            scores(1:length(scores_in)) = scores_in;
            x_out = (obj.coeff*scores(:))';
            
            if obj.mean_centered;
                x_out = x_out +obj.Xm;
            end
        end
        
    end
    
end

