classdef LossFunctions
    %LOSSFUNCTIONS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function obj = LossFunctions()
            %LOSSFUNCTIONS Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        
        function y = huber_loss(x,c)
            ix_h = abs(x)>=c;
            ix_l = abs(x)<c;
            y = nan(size(x));
            y(ix_l) = x(ix_l).^2/2;
            y(ix_h) = c*(abs(x(ix_h)) - c/2);
        end
        
        function y = biweight_loss(x,c)
            y =  1-(1 - x.^2/c^2).^2.*(abs(x)<c);
        end
        
        function y = hybrid_log(x,c)
            ix_h = abs(x)>=c;
            ix_l = abs(x)<c;
            y = nan(size(x));
            y(ix_l) = x(ix_l).^2;
            
            a = 2*c^2;
            b = c^2 - 2*c^2*log(c);
            y(ix_h) = a*log(abs(x(ix_h)))+b;
        end
         
        function y = absolute_loss(x,c)
            y = abs(x);
        end
         
    end
end

