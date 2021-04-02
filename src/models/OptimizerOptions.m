classdef OptimizerOptions
    %OPTIMIZEROPTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        optimizer_args
        outlier_args
        loss_fun_args
    end
    methods
        function obj = OptimizerOptions()
            obj.optimizer_args = {};
            obj.outlier_args = {};
            obj.loss_fun_args = {};
        end
    end
end

