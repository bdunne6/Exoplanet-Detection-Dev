classdef (Abstract) Optimizer
    %OPTIMIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
        init_params
        options
        obj_fun
    end
    
    methods (Abstract)
        optimize(obj)
    end
end

