classdef (Abstract) ImageComponentProblem
    %ImageReconstructionProblem:
    
    properties (Abstract = true)
        image_components
        observed_image
        optimizer
    end
    methods (Abstract)
        obj_fun(obj,free_params,fixed_params,point_pairs)
        optimize(obj)
    end
    
    methods (Static)
        %Input parsing and validation for any ImageComponentProblem implementation.
        function [image_components,observed_image,optimizer] = parse_constructor_inputs(args_in)
            if numel(args_in) ~=3
                error('CalibrationProblem constructor requires 4 arguments.')
            end
            [image_components,observed_image,optimizer] = args_in{:};
            %check first input
            assert(isa(image_components,'ImageComponent'),'Error: First input must be a scalar or array ImageComponent.')
            
            %check second input
            %assert(all(cellfun(@(x) isa(x,'ObservedImage'),observed_image)),'Error: Third input must be...');
            
            %check third input
            assert(isa(optimizer,'Optimizer'),'Error: Fourth input must be an Optimizer.');
        end
    end
end

