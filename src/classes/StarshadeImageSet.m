classdef StarshadeImageSet < matlab.mixin.Copyable
    %STARSHADEIMAGESET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        instrument_meta
        images
    end
    
    properties (Access = private)
        default_ignore = {'fits_info','file_path','file_name'};
    end
    
    methods
        function obj = StarshadeImageSet(varargin)
            %STARSHADEIMAGESET Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser;
            p.addOptional('image_folder','',@ischar);
            p.addOptional('load_now',0);
            
            p.parse(varargin{:});
            a = p.Results;
            
            if ~isempty(a.image_folder)
                fits_files = dir(fullfile(a.image_folder,'*.fits'));
                clear('images')
                for i1 = 1:numel(fits_files)
                    fits_pathi1 = fullfile(fits_files(i1).folder,fits_files(i1).name);
                    images(i1) = StarshadeImage(fits_pathi1,a.load_now);
                end
                
                obj.images = images;
            end
        end
        
        function [img_set_new,i_selected] = select(obj,varargin)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            p = inputParser;
            p.addParameter('equal',[]);
            p.addParameter('less_than',[]);
            p.addParameter('greater_than',[]);
            
            p.parse(varargin{:});
            a = p.Results;
            
            scomp = a.equal;
            
            meta_vals = cat(1,obj.images.meta);
            meta_fields = fieldnames(meta_vals);
            cell_vals = struct2cell(meta_vals);
            
            comp_fields = fieldnames(scomp);
            %cell_comp = struct2cell(scomp);
            %cellfun
            
            
            i_comp = ismember(meta_fields,comp_fields);
            cell_vals = cell_vals(i_comp,:);
            struct_vals = cell2struct(cell_vals,meta_fields(i_comp));
            
            
            i_selected = false(1,size(cell_vals,2));
            for i1 = 1:numel(struct_vals)
                i_selected(i1) = isequal(scomp,struct_vals(i1));
            end
            
            img_set_new = StarshadeImageSet();
            img_set_new.images = obj.images(i_selected);
            img_set_new.instrument_meta = obj.instrument_meta;
        end
        
        function iu = unique(obj,comp_fields)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            meta_vals = cat(1,obj.images.meta);
            meta_fields = fieldnames(meta_vals);
            cell_vals = struct2cell(meta_vals);
            
            i_comp = ismember(meta_fields,comp_fields);
            cell_vals = cell_vals(i_comp,:);
            struct_vals = cell2struct(cell_vals,meta_fields(i_comp));
            
            hashes = cell(1,size(cell_vals,2));
            for i1 = 1:numel(struct_vals)
                hashes{i1} = DataHash(struct_vals(i1));
            end
            [~,~,iu] = unique(hashes);
        end
        
        function img_set_new = stack_by(obj,comp_fields)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
            excluded_fields = [obj.default_ignore(:); comp_fields(:)];
            obj_fields = fieldnames(obj.images(1).meta(1));
            ufields = setdiff(obj_fields,excluded_fields);
            
            u_indices = obj.unique(ufields);
            
            u_ids = unique(u_indices);
            clear('images_new');
            for i1 = 1:numel(u_ids)
                i_imagesi1 = u_ids(i1) == u_indices;
                metai1 = cat(1,obj.images(i_imagesi1).meta);
                datai1 = cat(3,obj.images(i_imagesi1).data);
                
                %create the array of output images
                images_new(i1) = StarshadeImage();
                images_new(i1).meta = metai1;
                images_new(i1).data = datai1;
            end
            
            img_set_new = StarshadeImageSet();
            img_set_new.images = images_new;
            img_set_new.instrument_meta = obj.instrument_meta;
        end
        
        function load(obj)
            for i1 = 1:numel(obj.images)
                obj.images(i1).load();
            end
        end
        
        function plot_all(obj,f1)
            n_images = numel(obj.images);
            tile_ratio_rc = 4/3;
            n_col = floor(sqrt(n_images*tile_ratio_rc));
            
            n_row = ceil(n_images / n_col);
            
            tile_size = [n_row,n_col];
            tile_2d = @(i,j) sub2ind(fliplr(tile_size),j,i);
            
            figure(f1);
            
            t1 = tiledlayout(tile_size(1),tile_size(2));
            
            t1.TileSpacing = 'compact';
            for i1 = 1:numel(obj.images)
                %imgi1 = obj.images.
                n_stack = size(obj.images(i1).data,3);
                if n_stack > 1
                    hs = [0,1.0; %red saturated
                        0.4 1.0]; %green saturated
                    ms_img1= obj.images(i1).data;
                    imgi1 = multi_spectral_to_rgb(ms_img1,hs,[min(ms_img1(:)), max(ms_img1(:))]);
                else
                    imgi1 = obj.images(i1).data;
                end
                nexttile(i1);
                imagesc(imgi1);
                title(obj.images(i1).meta.file_name,'Interpreter','none');
            end
            
        end
        
        
    end
end


