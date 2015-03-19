classdef subplotter < sl.obj.display_class
    %
    %   Class:
    %   sl.plot.subplotter
    
    %sp = sl.plot.subplot(3,2)
%sp.p(1,1)
%plot()
%sp.clean()
%sp.title
%sp.xlabel
%sp.ylabel
%... = sp.handles
%
%   Both of the below methods require
%   TODO: We could allow passing in columns with which to work
%   like only work with a given set of columns ...
%sp.setColWidthByTime
%sp.setColWidthByPct

    
    properties
        dims
        handles
        last_index = 0
        %This can be used to omit specification of the axes
        %when calling the axes() method
        
        row_first_indexing %logical (default true)
        %
        %
        %
    end
    
    methods
        function obj = subplotter(n_rows,n_columns,varargin)
            %
            %   obj = sl.plot.subplotter(n_rows,n_columns)
            %
            %   Note, as much as I would like to be able to support
            %   
            %   Optional Inputs
            %   ---------------
            %   row_first_indexing : logical (default true)
            %       NOT YET IMPLEMENTED
            %       
            
            in.row_first_indexing = true;
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(n_rows)
                obj.dims = n_columns;
            else
                obj.dims = [n_rows,n_columns];
            end
            
            obj.row_first_indexing = in.row_first_indexing;
        end
        function axes(obj,row,column)
           %
           %    Calling Forms:
           %    --------------
           %    1) Specify the index to make active
           %    axes(obj,index)
           %
           %    2) Specify the location to make active by row & column
           %    axes(obj,row,column)
           %
           %    3) Make the next axes active (increment index by 1)
           %    axes(obj)
           %    
           %    The goals is to have this be equivalent
           %    to calling subplot()
           %
           %    1) call subplot
           %
           %    Improvement:
           %    ------------
           %    1) Implement row_first_indexing
           %    2) 
           %
           %    sp = sl.plot.subplotter
        
           error('Not yet implemented')
           
           %
           keyboard
           if nargin == 0
              %Use last index 
           elseif nargin == 1
               sp_index = row; 
           else
               %1 2
               %3 4
               %NOTE: This is currently for row_first_indexing = true
               sp_index = column + (row-1)*obj.dims(2);
           end
           obj.last_index = sp_index;
        end
        function setColWidthByTime(obj)
            %x Adjust column widths so that they are proportional to time
            %
            %   setColWidthByTime(obj)
            %
            %   This function adjusts column widths so that column
            %   widths are proportional to their time. In other words
            %   if one column spans 1 second and another 2 seconds, the
            %   latter column would be made to take up 2/3 of the available
            %   width.
            %
            %Yikes, I wonder if this is going to change my xlim
            %which would make this circular ...
            %
            %   TODO: Units need to be normalized ...

           all_positions = get(obj.handles(1,:),'position');
           all_xlims     = get(obj.handles(1,:),'xlim');

           all_lefts = cellfun(@(x) x(1),all_positions);
           all_rights = cellfun(@(x) x(1)+x(3),all_positions);
           
           left_extent  = all_lefts(1);
           right_extent = all_rights(end);
           
           all_widths = all_rights - all_lefts;
           all_time_durations = cellfun(@(x) x(2)-x(1),all_xlims);
           
           total_width = sum(all_widths);
           
           pct_durations = all_time_durations/sum(all_time_durations);
           new_widths = pct_durations*total_width;
           
           gap_widths = all_lefts(2:end) - all_rights(1:end-1);
           
           next_left = left_extent;
           n_columns = obj.dims(2);
           n_rows = obj.dims(1);
           for iColumn = 1:n_columns
               cur_width = new_widths(iColumn);
               for iRow = 1:n_rows
                  cur_position = get(obj.handles(iRow,iColumn),'position');
                  cur_position(1) = next_left;
                  cur_position(3) = cur_width;
                  set(obj.handles(iRow,iColumn),'position',cur_position)
               end
               if iColumn ~= n_columns
                  next_left = next_left + cur_width + gap_widths(iColumn); 
               end
           end
        end
        function removeVerticalGap(obj,rows,columns,varargin)
           %x 
           %
           %    removeVerticalGap(obj,rows,columns,varargin)
           %
           %    rows : 
           %        Must be more than 1, should be continuous, starts at 
           %        the top
           %
           %    Optional Inputs:
           %    ----------------
           %    remove_x_labels : logical (default true)
           %
           %    
           
           %{
           subplot(2,1,1)
           plot(1:10)
           xlabel('testing')
           subplot(2,1,2)
           plot(2:20)
           xlabel('testing')
           sp = sl.plot.subplotter.fromFigure(gcf)
           sp.removeVerticalGap(1:2,1)
           %}
           
           in.remove_x_labels = true;
           in.remove_x_ticks = true;
           in = sl.in.processVarargin(in,varargin);
           
           %What's our expansion algorithm??????
           %Outer Position
           
           for iRow = 1:length(rows)-1
               cur_row_I = rows(iRow);
               for iCol = 1:length(columns)
                   cur_col_I = columns(iCol);
                   cur_ax = obj.handles{cur_row_I,cur_col_I};
                   a = sl.hg.axes(cur_ax);
                   a.clearLabel('x');
                   a.clearTicks('x');
               end
           end
           
           %Assuming all columns are the same ...
           top_axes    = sl.hg.axes(obj.handles{rows(1),columns(1)});
           bottom_axes = sl.hg.axes(obj.handles{rows(end),columns(1)});

           %Add 1 due to edges
           %
           %        top     row 1   TOP OF TOP AXES
           %
           %        bottom  row 1  & top row 2
           %
           %        bottom  row 2  & top row 3
           %
           %        bottom  row 3   BOTTOM OF BOTTOM AXES
           %
           %    fill in so that each axes has the same height and so that
           %    all axes span from the top of the top axes to the bottom of
           %    the bottom axes
           temp = linspace(bottom_axes.position.bottom,top_axes.position.top,length(rows)+1);
           new_bottoms = temp(end-1:-1:1);
           new_tops = temp(end:-1:2);
           
           for iRow = 1:length(rows)
               cur_row_I = rows(iRow);
               cur_top = new_tops(iRow);
               cur_bottom = new_bottoms(iRow);
               for iCol = 1:length(columns)
                   cur_col_I = columns(iCol);
                   cur_ax = obj.handles{cur_row_I,cur_col_I};
                   a = sl.hg.axes(cur_ax);
                   a.position.top = cur_top;
                   a.position.bottom = cur_bottom;
               end
           end
           %TODO: Verify continuity of rows
           %TODO: Verify same axes if removing x labels ...
        end
    end
    methods (Static)
        function obj = fromFigure(fig_handle)
            %
            %
            %   sp = sl.plot.subplotter.fromFigure(fig_handle)
            %
            %
           temp = sl.hg.figure.getSubplotAxesHandles(fig_handle);
           
           sz = size(temp.grid_handles);
           
           obj = sl.plot.subplotter(sz(1),sz(2));
           obj.handles = num2cell(temp.grid_handles);
           
        end
    end
    
end

