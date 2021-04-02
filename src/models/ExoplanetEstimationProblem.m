classdef ExoplanetEstimationProblem < ImageComponentProblem
    %ExoplanetEstimationProblem:
    
    properties
        image_components
        image_components_fixed
        observed_image
        optimizer
    end
    
    methods
        function obj = ExoplanetEstimationProblem(varargin)
            %parse and validate inputs using method from base class
            [obj.image_components,obj.observed_image,obj.optimizer] = obj.parse_constructor_inputs(varargin);
            
            %set up image_components_fixed with same structure as image_components but with all params as NaN i.e. not fixed.
            obj.image_components_fixed = obj.image_components.devectorize_params(obj.image_components.vectorize_params()*NaN);
        end
        
        function model_error = obj_fun(obj,free_params,fixed_params,debug_flag,verbose)
            %take full param vector from fixed_param and plug in free parameters
            combined_params = fixed_params;
            combined_params(isnan(fixed_params)) = free_params;
            
            %get the image components in object form based on the combined_params vector
            img_comp_loc = obj.image_components.devectorize_params(combined_params);
            
            %append errors(TODO think through multi-spectral case)
            model_error =[];
            for i1 = 1:numel(img_comp_loc)
                img_compi1 = img_comp_loc(i1).get_component();
                errori1 = obj.observed_image-img_compi1;
                errori1(isnan(errori1)) = [];
                model_error = [model_error;errori1(:)];
                %                 if debug_flag
                %                     obj.plot_reconstruction(observed_image,image_components,fignum,fig_reset,draw_fig));
                %                 end
            end
        end
        
        function [image_components_opt, residual, estimated_image ,i_outlier,cnt] = optimize(obj,varargin)
            %parse input
            parser = inputParser();
            parser.addParameter('debug_flag',0)
            parser.addParameter('verbose',0)
            parser.parse(varargin{:});
            pargin = parser.Results;
            debug_flag=pargin.debug_flag;
            verbose=pargin.verbose;
            
            %set up the objective function using initial and fixed parameters.
            init_params = obj.image_components.vectorize_params();
            fixed_params = obj.image_components_fixed.vectorize_params();
            init_params = init_params(isnan(fixed_params));
            obj_fun_loc = @(x) (obj.obj_fun(x,fixed_params,debug_flag,verbose));%get a handle to the objective fun with just one argument
            
            %pass the objective function and initial guess to the optimizer object and optimize
            obj.optimizer.obj_fun = obj_fun_loc;
            obj.optimizer.init_params = init_params;
            [params_opt,i_outlier,SS, cnt] = obj.optimizer.optimize();
            
            %combine the optimal params with any fixed params
            determined_params=fixed_params;
            determined_params(isnan(fixed_params)) = params_opt;
            image_components_opt = obj.image_components.devectorize_params(determined_params);
            
            %collect the residual
            residual = [];
            for i1 = 1:numel(image_components_opt)
                estimated_image = image_components_opt(i1).get_component();
                residual = obj.observed_image - estimated_image;
            end
        end
        
    end
    
    methods (Static)
        %         function plot_reconstruction(observed_image,image_components,fignum,fig_reset,draw_fig)
        %         end
    end
end

