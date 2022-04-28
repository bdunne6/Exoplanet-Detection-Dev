classdef SimpleExozodi < ImageComponent
    %SimpleExozodi: A simple parametric model of exozodiacal dust
    
    properties
        img_size %size of the image to generate
        intensity_scale %intensity scale factor
        axes_ratio %ratio of minor axis to major axis (i.e. disk inclination)
        orientation %rotation in the image plane
        center_xy %center of pattern in the image
        exp_scale %scale factor for decaying exponential
        poly_coeff %polynominal model for decaying exponential
    end
    
    properties (Access = private)
        %meshgrids for x and y
        Xg
        Yg
    end
    
    properties (Hidden = true,Constant=true)
        %specification of subset of properties to be varied in an estimation problem
        free_params = {'intensity_scale','axes_ratio','orientation','center_xy','exp_scale','poly_coeff'};
        %free_params = {'intensity_scale','axes_ratio','orientation','center_xy','poly_coeff'};
    end
    
    methods
        function obj = SimpleExozodi(img_size)
            %construction from target image size
            ny = img_size(1);
            nx = img_size(2);
            
            [Xg,Yg] = meshgrid(1:nx,1:ny);
            
            [ny,nx] = size(Xg);
            xc = (nx-1)/2;
            yc = (ny-1)/2;
            
            obj.img_size = img_size;
            obj.center_xy = [xc,yc];
            obj.Xg = Xg;
            obj.Yg = Yg;
        end
        
        function img_comp = get_component(obj,varargin)
            img_comp = obj.generate_disk_static(obj);
        end
        
        function apply_component(obj,img_in)
            
            
        end
        
    end
    
    
    methods  (Static)
        function [disk] = generate_disk_static(mdl)
            %generate_disk_static Summary of this function goes here
            %   Detailed explanation goes here
            
            s = mdl.intensity_scale;
            a = 1;
            b = a*mdl.axes_ratio;
            o = mdl.orientation;
            xc = mdl.center_xy(1);
            yc = mdl.center_xy(2);
            e_scale = mdl.exp_scale;
            p_coeff = mdl.poly_coeff;
            
            Xgc = mdl.Xg - xc;
            Ygc = mdl.Yg - yc;
            
            %https://math.stackexchange.com/questions/426150/what-is-the-general-equation-of-the-ellipse-that-is-not-in-the-origin-and-rotate
            m_dist = sqrt((Xgc*cos(o) + Ygc*sin(o)).^2*a^(-2) + (Xgc*sin(o) - Ygc*cos(o)).^2*b^(-2));
            disk = s*exp(polyval(p_coeff,m_dist)/e_scale);
            %disk = s*polyval(p_coeff,m_dist);
        end
    end
end
