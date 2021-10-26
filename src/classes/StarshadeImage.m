classdef StarshadeImage < matlab.mixin.Copyable
    %STARSHADEIMAGE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        meta
        data
        roi %[x,y,w,h]
    end

    properties (Dependent)
        data_roi
    end

    methods
        function obj = StarshadeImage(varargin)
            %STARSHADEIMAGE Construct an instance of this class
            %   Detailed explanation goes here

            %STARSHADEIMAGESET Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser;
            p.addOptional('file_path','',@ischar);
            p.addOptional('load_now',0);

            p.parse(varargin{:});
            a = p.Results;

            if ~isempty(a.file_path)
                info = fitsinfo(a.file_path);

                [~,file_name,ext] =fileparts(a.file_path);
                file_name= [file_name,ext];
                name_parts = strsplit(file_name,'_');

                clear('meta');
                %add image data and meta-data to a struct array
                meta.file_name = file_name;
                meta.file_path = a.file_path;
                meta.fits_info = info;
                meta.RH = name_parts{2}(1);
                meta.scenario = str2double(name_parts{2}(2:end));
                meta.visit_num = str2double(name_parts{3}(2:end));
                meta.exozodi_model = name_parts{4}(1:end-1);
                meta.exozodi_intensity = str2double(name_parts{4}(4:end));
                meta.snr_level = str2double(name_parts{5}(4:end));
                meta.passband = [str2double(name_parts{6}),str2double(name_parts{7})];
                rparts = strsplit(name_parts{9},'.');
                meta.release = str2double(rparts{1}(2:end));

                obj.meta = meta;

                if a.load_now
                    obj.load();
                end
            end
        end

        function img1 = load(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            img1 = [];

            for i1 = 1:numel(obj.meta)
                img1 = cat(3,img1,fitsread(obj.meta(i1).file_path,'raw'));
            end

            if nargout == 0
                obj.data = img1;
            end
        end


        function val = get.data_roi(obj)
            roi_1 = obj.roi;
            if ~isempty(roi_1)
                rows = roi_1(2):roi_1(2)+roi_1(4)-1;
                cols = roi_1(1):roi_1(1)+roi_1(3)-1;
                val = obj.data(rows,cols,:);
            else
                val = obj.data;
            end
        end

        function set.data_roi(obj,val)
            roi_1 = obj.roi;
            if ~isempty(roi_1)
                rows = roi_1(2):roi_1(2)+roi_1(4)-1;
                cols = roi_1(1):roi_1(1)+roi_1(3)-1;
                obj.data(rows,cols,:) = val;
            else
                obj.data = val;
            end
        end

    end
end