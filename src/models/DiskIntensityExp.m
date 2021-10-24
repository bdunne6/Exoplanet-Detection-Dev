classdef DiskIntensityExp < ParameterSet
    %DISKINTENSITYEXP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        exp_scale %scale factor for decaying exponential
        poly_coeff %polynominal model for decaying exponential
    end
    
    
    properties (Hidden = true,Constant=true)
        %specification of subset of properties to be varied in an estimation problem
        free_params = {'exp_scale','poly_coeff'};
    end
    
    methods
        function obj = DiskIntensityExp()
            %DiskIntensityExp Construct an instance of this class
            %   Detailed explanation goes here
            %obj.Property1 = inputArg1 + inputArg2;
        end
        
        function intensity_map = apply_function(obj,x)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            intensity_map = exp(polyval(obj.poly_coeff,x)/obj.exp_scale);
        end
    end
end

