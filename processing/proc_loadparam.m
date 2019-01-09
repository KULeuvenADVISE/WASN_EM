function chain = proc_loadparam(chain_str,dir_str,input_shape,gen)
% ----------------------------------------------------------------------
%  Function to read the processing chain from the yaml file
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: chain = proc_loadparam(chain_str,input_shape,gen)
% Inputs:
% (1) chain_str         Processing chain str, refers to yaml file [str]
% (2) dir_str           Processing chain str, refers to yaml file [str]
% (3) input_shape      	optional input_shape overload. If empty, parameters defined in model yaml are used
% (4) gen               containing values that could be used as constant value overload in the yaml file
% Outputs:
% (1) chain             Processing chain parameters [struct]      

% Prepare format to overload input shape in the loaded model
if ~isempty(input_shape)
chid = gen.chid; featid = gen.featid; frameid = gen.frameid;
gen.CHANNELS = input_shape(chid);
gen.FEATURE_VECTOR_LENGTH = input_shape(featid);
gen.INPUT_SEQUENCE_LENGTH = input_shape(frameid);
end

if isempty(dir_str)&&~ischar(dir_str) % if empty, use default
    dir_str = fullfile('processing','chains');
end

chain = process_yaml(chain_str,dir_str,gen);

% Add default memory related parameters in case these are missing
for lid = 1:size(chain,1) %for every layer
    % get settings
    tmp = chain{lid,3};
    % inject default params in case not given for particular layer
    if ~isfield(tmp,'parameters')
        tmp.parameters = gen.stand_mem;
    end
    if ~isfield(tmp,'output')
        tmp.output = gen.stand_mem;
    end
    if ~isfield(tmp,'S')
        tmp.S = gen.S;
    end
    if gen.stand_mem_ow
        tmp.parameters = gen.stand_mem;
        tmp.output = gen.stand_mem;
    end
    if ~isfield(tmp,'output_save')
        tmp.output_save = gen.stand_outsave;
    end
    if ~isfield(tmp,'output_acc')
        tmp.output_acc = gen.stand_outacc;
    end
    % save
    chain{lid,3} = tmp;
end
