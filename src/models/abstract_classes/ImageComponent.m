classdef (Abstract) ImageComponent
    %ImageComponent : Abstract class to define a component of a parametric image model.
    methods (Abstract)
        get_component()
        apply_component(img_in)
    end
    
    properties (Abstract,Constant=true)
       free_params 
    end
    
    methods
        function params_vect = vectorize_params(obj)
            %concatenate all free properties into one vector for optimization
            params_vect = [];
            for i1 = 1:numel(obj)
                free_params_i1 = obj(i1).free_params;
                for i2 = 1:numel(free_params_i1)
                    params_vect = [params_vect, obj(i1).(free_params_i1{i2})(:)'];
                end
            end
        end
        
        function obj = devectorize_params(obj,params_vect)
            %use the current object as a template to devectorize a param vector back into an obj
            i_vect = 1;
            for i1 = 1:numel(obj)
                free_params_i1 = obj(i1).free_params;
                for i2 = 1:numel(free_params_i1)
                    Ni1 = numel(obj(i1).(free_params_i1{i2}));
                    obj(i1).(free_params_i1{i2}) = params_vect(i_vect:i_vect+Ni1-1);
                    i_vect = i_vect+Ni1;
                end
            end
        end
    end
    
end

