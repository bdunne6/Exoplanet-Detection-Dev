classdef (Abstract) ImageComponent < ParameterSet
    %ImageComponent : Abstract class to define a component of a parametric image model.
    methods (Abstract)
        get_component()
        apply_component(img_in)
    end
end

