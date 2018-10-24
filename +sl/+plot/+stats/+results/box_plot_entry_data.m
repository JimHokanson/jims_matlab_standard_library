classdef box_plot_entry_data < handle
    %
    %   Class:
    %   sl.plot.stats.results.box_plot_entry_data
    %
    %   See Also
    %   --------
    %   sl.plot.stats.results.box_plot_entry
    
    properties
        raw
        non_outlier_data
        rng_seed
        x_center
        box_width
        pct_box_width_scatter
        h_scatter
        n_data_points
        n_data_points_no_outliers
    end
    
    methods
        function obj = box_plot_entry_data(raw,outlier_y_data,box_width,x_center)
            %
            %   obj = sl.plot.stats.results.box_plot_entry_data(raw,box_width,x_center)
                        
            %I think == is ok because of how the data are generated ...
            outlier_mask = outlier_y_data == raw; 
            
            obj.raw = raw;
            obj.non_outlier_data = raw(~outlier_mask);
            
            obj.n_data_points = sum(~isnan(raw));
            obj.n_data_points_no_outliers = sum(~isnan(obj.non_outlier_data));
            
            obj.rng_seed = 9;
            obj.x_center = x_center;
            obj.box_width = box_width;
        end
        function renderScatterData(obj,varargin)
            %
            %
            %   
            
            %TODO: We could allow different sizes as well ...
            
            in.marker = 'o';
            in.color = 'k';
            in.alpha = 0.6;
            in.rng_seed = 9;
            in.marker_size = 100;
            in.pct_width = 0.5;
            in = sl.in.processVarargin(in,varargin);
            
            obj.rng_seed = in.rng_seed;
            obj.pct_box_width_scatter = in.pct_width;
            
            r1 = rng(in.rng_seed);
            x1 = rand(1,length(obj.non_outlier_data));
            x1 = x1./max(x1);
            rng(r1);
            
            x_min = obj.x_center - in.pct_width*obj.box_width/2;
            total_width = obj.box_width*in.pct_width;
            
            x2 = (x1.*total_width)+x_min;
            
            %TODO: Ideally we would maintain state instead of hold off
            %i.e. only off if it was off previously
            hold on
            obj.h_scatter = scatter(x2,obj.non_outlier_data,in.marker_size,...
                'Marker',in.marker,...
                'MarkerEdgeColor','none',...
                'MarkerFaceColor',in.color,...
                'MarkerFaceAlpha',in.alpha);
            hold off
            
        end
        function moveX(obj,new_x_value)
            
        end
        function changeWidth(obj,new_width)
            old_width = obj.box_width; 
        end
    end
end
