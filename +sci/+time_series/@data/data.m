classdef data < handle
    %
    %   Class:
    %   sci.time_series.data
    %
    %
    %   Methods to implement:
    %   - allow merging of multiple objects (input as an array or cell
    %       array) into a single object - must have same length and time
    %       and maybe units
    %   - allow plotting of channels as stacked or as subplots
    %   - averaging to a stimulus
    
    properties
        d    %numeric array
        time     %sci.time_series.time
        units
        n_channels
    end
    
    properties 
       history = {}
    end
    
    %Optional properties -------------------------------------------------
    properties
        
    end
    
    methods
        function obj = data(data_in,time_object_or_dt,varargin)
            %
            %    How to handle multiple channels?
            %
            %    obj = sci.time_series.data(data_in,time_object,varargin)
            %
            %    obj = sci.time_series.data(data_in,dt,varargin)
            %
            %   Optional Inputs:
            %   ----------------
            %   history: 
            %   units:
            %   channel_labels:
            %
            %    data_in must be with samples going down the rows
            
            in.history = {};
            in.units = 'Unknown';
            in.channel_labels = ''; %TODO: If numeric, change to string ...
            in = sl.in.processVarargin(in,varargin);
            
            obj.n_channels = size(data_in,1);
            
            obj.d = data_in;
            
            if isobject(time_object_or_dt)
                obj.time = time_object_or_dt;
            else
                obj.time = sci.time_series.time(time_object_or_dt,obj.n_channels);
            end
            
            obj.units = in.units;
            
            obj.history = in.history;
        end
        function plot(obj,channels)
            if ~exist('channels','var')
                temp = sl.plot.big_data.LinePlotReducer(obj.time,obj.d);
            else
                temp = sl.plot.big_data.LinePlotReducer(obj.time,obj.d(:,channels));
            end
            temp.renderData();
        end
        function addHistoryElements(obj,history_elements)
            if iscell(history_elements);
                if size(history_elements,2) > 1
                    history_elements = history_elements';
                end
            elseif ~ischar(history_elements)
                error('Invalid history element type')
            end
            
            obj.history = [obj.history; history_elements];
        end
    end
    
end
