classdef SimplexOptimizer < Optimizer
    %LMOPTIMIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        init_params
        options = {};
        obj_fun
    end
    
    methods
        function obj = SimplexOptimizer(varargin)
            %SimplexOptimizer Construct an instance of this class
            %   Detailed explanation goes here
            if numel(varargin)==3
                [cost_fun,init_params,options] = varargin{:};
                obj.cost_fun = cost_fun;
                obj.init_params = init_params;
                obj.options = options;
                obj.loss_fun = [];
            end
        end
        %'MaxIter',200,'Basdx',1e-7,'XTol',1e-9,'FunTol',1e-9
        function [x_opt,i_outliers, SS, cnt, res, XY] = optimize(obj,varargin)
            
            %parse the options property with backward compatibility for single cell
            [lm_args,outlier_args,loss_args] = parse_options_property(obj);
            %
            args = obj.parse_optimize_input([outlier_args,loss_args]);
            %initialize outlier logical indices as false
            i_outliers = false(size(obj.obj_fun(obj.init_params)));
            if args.outlier_threshold < Inf
                [i_outliers,obj.init_params] = obj.detect_outliers(i_outliers,args.outlier_threshold,lm_args);
            end
            %perform final fit with specified loss function and any outliers removed
            loc_obj_fun = obj.get_objective_function(~i_outliers,args.loss_function,args.loss_threshold);
            tic
            [x_opt, SS] = fminsearch(loc_obj_fun,obj.init_params);
            toc
            %[x_opt, SS, cnt, res, XY] = LMFnlsq2(loc_obj_fun ,obj.init_params,lm_args{:});
            i_outliers = any(reshape(i_outliers,[numel(i_outliers)/2,  2]),2);
        end
        
        function obj_fun1 = get_objective_function(obj,i_valid,loss_function,loss_threshold)
            %get objective function for specific residual indices and loss function
            index_at = @(expr, index) expr(index);
            get_selected_residuals = @(x) index_at(obj.obj_fun(x),i_valid);
            switch loss_function
                %sqrt() is added to loss functions since the optimizer is going to look at sum of squares
                case 'huber'
                    obj_fun = @(x) sqrt(LossFunctions.huber_loss(get_selected_residuals(x),loss_threshold));
                case 'biweight'
                    obj_fun = @(x) sqrt(LossFunctions.biweight_loss(get_selected_residuals(x),loss_threshold));
                case 'hybrid_log'
                    obj_fun = @(x) sqrt(LossFunctions.hybrid_log(get_selected_residuals(x),loss_threshold));
                case 'none'
                    obj_fun = get_selected_residuals;
                otherwise
                    assert(false,'Loss function not recognized.');
            end
            obj_fun1 = @(x) (sum(obj_fun(x).^2));
        end
        
        function [i_outliers,x_opt] = detect_outliers(obj,i_outliers,th,lm_args)
            %use hybrid log loss to fit robustly with outliers present
            loc_obj_fun = obj.get_objective_function(~i_outliers,'hybrid_log',1);
            x_opt = LMFnlsq2(loc_obj_fun ,obj.init_params,lm_args{:});
            %flag high errors after hybrid log fit as outliers.
            i_outliers = (abs(obj.obj_fun(x_opt)) > th);
        end
        
        function [lm_args,outlier_args,loss_args] = parse_options_property(obj)
            %parse obj.options to check if it's a legacy cell vs OptimizerOptions class
            if iscell(obj.options)
                lm_args = obj.options;
                outlier_args = {};
                loss_args = {};
                return
            elseif isa(obj.options,'OptimizerOptions')
                lm_args = obj.options.optimizer_args;
                outlier_args = obj.options.outlier_args;
                loss_args = obj.options.loss_fun_args;
            end
        end
        
    end
    
    methods  (Static)
        function args_out = parse_optimize_input(args_in)
            p = inputParser();
            p.addParameter('outlier_threshold',Inf);
            p.addParameter('loss_function','none');
            p.addParameter('loss_threshold',Inf);
            p.parse(args_in{:});
            args_out = p.Results;
        end

    end
end

