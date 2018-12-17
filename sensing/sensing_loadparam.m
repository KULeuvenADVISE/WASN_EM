function sensing_param = sensing_loadparam(sensing_str,param_dir,gen_param)
% ----------------------------------------------------------------------
%  Function to read the sensing config from the yaml file
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: general_param = sensing_loadparam(feat_str,gen_param)
% Inputs:
% (1) sensing_str       sensing config str str, refers to yaml file [str]
% (2) param_dir      	directory of string if where the params are located - optional [str]
% (3) gen_param      	gen_param, that could be used as constant value overload in the yaml file
% Outputs:
% (1) sensing_param     sensing config parameters [struct]      

if nargin~=2, gen_param = struct; end; % no parameter overloading

if isempty(param_dir) % if empty, use default
    param_dir = fullfile('sensing','params');
end

sensing_param = process_yaml(sensing_str,param_dir,gen_param);
