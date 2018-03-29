classdef setConfig
    
    properties
        
        instrName
        paramName
        modeName
        displayName
        displayParam
        formatName
        stationName
        auxData
        fileName
        configOK
        processingParam
		
    end
    
    methods
        
        function obj=setConfig(configFile)
            
            % open config file
            fid=fopen(configFile);
            if fid==-1
                disp('config file not found ...');
                return
            end
            
            % evaluate config file
            while feof(fid)==0
                eval(fgetl(fid));
            end
            
            % close config file
            fclose(fid);
            
            % get properties
            props=properties(obj);
            
            % attribute values from config file
            for i=1:length(props)
                if exist(props{i},'var')==1
                    obj.(props{i}) = eval(props{i});
                elseif strcmp(props{i},'configOK')==0
                    disp([props{i} ' not defined in config file'])
                end
            end
                        
            % check output file names
            obj.configOK=1;
            for h=1:length(obj.instrName);
                for j=1:length(obj.paramName)
                    for k=1:length(obj.modeName)
                        for m=1:length(obj.displayName)
                            for l=1:length(obj.formatName)
                                for i=1:length(obj.stationName)
                                    if isfield(obj.fileName,obj.instrName{h})==0
                                        disp(sprintf('missing filename for %s',obj.instrName{h}));
                                        obj.configOK=0;
                                        return
                                    end
                                    if isfield(obj.fileName.(obj.instrName{h}),char(obj.paramName{j}))==0
                                        disp(sprintf('missing filename for %s.%s',obj.instrName{h},obj.paramName{h}));
                                        obj.configOK=0;
                                        return
                                    end
                                    if isfield(obj.fileName.(obj.instrName{h}).(obj.paramName{j}),char(obj.modeName{k}))==0
                                        disp(sprintf('missing filename for %s.%s.%s',obj.instrName{h},obj.paramName{h},obj.modeName{h}));
                                        obj.configOK=0;
                                        return
                                    end
                                    if isfield(obj.fileName.(obj.instrName{h}).(obj.paramName{j}).(obj.modeName{k}),char(obj.displayName{m}))==0
                                        disp(sprintf('missing filename for %s.%s.%s.%s',obj.instrName{h},obj.paramName{h},obj.modeName{h},obj.displayName{h}));
                                        obj.configOK=0;
                                        return
                                    end
                                    if isfield(obj.fileName.(obj.instrName{h}).(obj.paramName{j}).(obj.modeName{k}).(obj.displayName{m}),char(obj.formatName{l}))==0
                                        disp(sprintf('missing filename for %s.%s.%s.%s.%s',obj.instrName{h},obj.paramName{h},obj.modeName{h},obj.displayName{h},obj.formatName{h}));
                                        obj.configOK=0;
                                        return
                                    end
                                    if isfield(obj.fileName.(obj.instrName{h}).(obj.paramName{j}).(obj.modeName{k}).(obj.displayName{m}).(obj.formatName{l}),char(obj.stationName{i}))==0
                                        disp(sprintf('missing filename for %s.%s.%s.%s.%s.%s',obj.instrName{h},obj.paramName{h},obj.modeName{h},obj.displayName{h},obj.formatName{h},obj.stationName{h}));
                                        obj.configOK=0;
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
        end
        
    end
    
end
