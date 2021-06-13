classdef StarshadeImage < matlab.mixin.Copyable
    %STARSHADEIMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        meta
        data
    end
    
    methods
        function obj = StarshadeImage(file_path,load_now)
            %STARSHADEIMAGE Construct an instance of this class
            %   Detailed explanation goes here
            
            
            info = fitsinfo(file_path);
            imgi1 = fitsread(file_path,'raw');
            [~,file_name,ext] =fileparts(file_path);
            file_name= [file_name,ext];
            name_parts = strsplit(file_name,'_');
            
            clear('image_data_i0')
            %add image data and meta-data to a struct array
            meta.file_path = file_path;
            meta.fits_info = info;
            meta.RH = name_parts{2}(1);
            meta.scenario = str2double(name_parts{2}(2:end));
            meta.visit_num = str2double(name_parts{3}(2:end));
            meta.exozodi_intensity = str2double(name_parts{4}(4:end));
            meta.snr_level = str2double(name_parts{5}(4:end));
            meta.passband = [str2double(name_parts{6}),str2double(name_parts{7})];
            rparts = strsplit(name_parts{9},'.');
            meta.release = str2double(rparts{1}(2:end));
            
            obj.meta = meta;
            
            if nargin > 1
                if load_now
                    obj.data = imgi1;
                end
            end
        end
        
        function img1 = load(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            img1 = fitsread(obj.meta.file_path,'raw');
            if nargout == 0
                obj.data = img1;
            end
        end
    end
end

