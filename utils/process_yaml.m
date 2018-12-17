% ----------------------------------------------------------------------
%  Function to read the sensing/general or chain config from the yaml file
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: output = process_yaml(yaml_str,dir_str,gen_param)
% Inputs:
% (1) yaml_str          config str, refers to yaml file [str]
% (2) dir_str           location of yam files [str]
% (2) gen_param      	gen_param, that could be used as constant value overload in the yaml file
% Outputs:
% (1) output            config parameters [struct]    

function output = process_yaml(yaml_str,dir_str,param_overload)
% Get yaml file
test = ReadYaml(fullfile(dir_str,[yaml_str '.yaml']));
% Get list of parameters used for parameter overloading or string
% replacement in equations
if isfield(test,'constants')
    const_fields = fieldnames(test.constants);
    for f=1:numel(const_fields) % loop over all constants
        if isfield(param_overload,const_fields{f})
            test.constants.(const_fields{f}) = param_overload.(const_fields{f});
        end
    end
else
    test.constants = struct;
end
if isfield(test, 'param') % regular parameter file
    output = test.param;
    output_field = fieldnames(output);
    tmp = struct;
    for c=1:length(output_field) % loop over each layer
%         if strcmp(output_field{c},'k')
%             lol = 1;
%         end
        output.(output_field{c}) = process_values(output.(output_field{c}),tmp); % overload from parameters in the own parameter list
        output.(output_field{c}) = process_values(output.(output_field{c}),test.constants); % overload from external constants
        tmp.(output_field{c}) = output.(output_field{c}); % keep prev parameters to use for the first overloading
    end
elseif isfield(test, 'chain') % model/feature config file
    for c=1:length(test.chain) % loop over each layer
        layer_names{c} = test.chain{c}.layer_name;
        if ~isfield(test.chain{c},'config')
            test.chain{c}.config = struct;
        end
        if ~isfield(test.chain{c},'memory')
            error(['Chain nr. ' num2str(c) ' does not have memory specifications.']);
        end
        config_fields = fieldnames(test.chain{c}.config); % get config fields
        for f=1:numel(config_fields) %loop over all configs
            % Overload constants to strings and optionally compute arithmetics
            tmp_all = process_values(test.chain{c}.config.(config_fields{f}),test.constants);
            % save
            test.chain{c}.config.(config_fields{f}) = tmp_all;
        end
        configs{c} = test.chain{c}.config; 
        memory_spec{c} = test.chain{c}.memory; 
    end
    output = [layer_names(:) configs(:) memory_spec(:)];
else
    error('Not a proper yaml file.');
end
end

function tmp_all = process_values(tmp_all,constants)
    % other
    const_fields = fieldnames(constants); % get field names
    if ~iscell(tmp_all) % make sure its a cell
        tmp_all = {tmp_all};
    end
    [~,I] = sort(cellfun(@length,const_fields)); % sort everything so no substring gets overloaded
    const_fields = const_fields(fliplr(I(:)'));
    % go over each cell and overload/compute parameters
    num_check = zeros(1,length(tmp_all));
    for k=1:length(tmp_all)
        tmp = tmp_all{k};
        % overload constant strings with values
        if isstring(tmp) || ischar(tmp) %if char or string
            tmp = strrep(tmp,' ','');
            tmp_done = zeros(1,length(tmp)); %done vector
            for f2=1:numel(const_fields) % loop over all constants
%                 if strcmp(const_fields{f2},'n') %||  strcmp(output_field{c},'k')
%                     lol = 1;
%                 end
                % Check if the string needs to be copied into an equation
                % or vector indexing
                index_start_all = strfind(tmp,const_fields{f2}); %get index of operatior before 
                index_stop_all = index_start_all+length(const_fields{f2})-1; %get index of operatior before    
                for i=1:length(index_start_all)
                    index_start = index_start_all(i);
                    index_stop = index_stop_all(i);
                    if ~isempty(index_start) && sum(tmp_done(index_start:index_stop))==0 %if a match and not a already replaced string
                        if equation_check(tmp(max(index_start,1))) || equation_check(tmp(min(index_stop,length(tmp)))) % if its due to equation
                            if isnumeric(constants.(const_fields{f2})) %if not numeric
                                if length(constants.(const_fields{f2}))==1 % create str to copy into equation
                                    repstr = num2str(constants.(const_fields{f2}));
                                else
                                    repstr = ['[' num2str(constants.(const_fields{f2})) ']'];
                                end
                            else
                                error;
                            end
                        elseif strcmp(tmp(min(index_stop+1,length(tmp))),'(') % if its scalar selection  
                            repstr = ['constants.' const_fields{f2}];
                        else %if parameter overloading
                            repstr = num2str(constants.(const_fields{f2}));
                        end
                        tmp = [tmp(1:index_start - 1), repstr, tmp(index_stop+1:end)]; % replace string
                        tmp_done = [tmp_done(1:index_start - 1) ones(1,length(repstr)) tmp_done(index_stop+1:end)]; % show it is used
                    end
                end
            end
        end

        % evaluate expressions
        if equation_check(tmp)
%             disp(tmp);
%             tmp2 = tmp;
            tmp = eval(tmp);
        end
        % Convert to numeric if needed
        if isstring(tmp) || ischar(tmp) %if char or string
            if all(ismember(tmp, '0123456789+-.eEdD')) %if numeric
            tmp = str2double(tmp);
            end
        end

        tmp_all{k} = tmp;
        num_check(k) = isnumeric(tmp);
    end
    % reformat output
    if length(tmp_all)==1 % back to original format
        tmp_all = tmp_all{1};
    elseif all(num_check)
        tmp_all = cell2mat(tmp_all);
    end
end

function check = equation_check(inp_str)
    if ~isempty(strfind(inp_str,'*')) || ~isempty(strfind(inp_str,'/')) || ~isempty(strfind(inp_str,'+')) || ~isempty(strfind(inp_str,'-'))
        check = true;
    else
        check = false;
    end
end