function comm_param = comm_loadparam(comm_str,param_dir,gen_param)
% ----------------------------------------------------------------------
%  Function to read the comm config from the yaml file
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: general_param = comm_loadparam(feat_str,gen_param)
% Inputs:
% (1) comm_str       comm config str str, refers to yaml file [str]
% (2) param_dir      	directory of string if where the params are located - optional [str]
% (3) gen_param      	gen_param, that could be used as constant value overload in the yaml file
% Outputs:
% (1) comm_param     comm config parameters [struct]      

if nargin~=2, gen_param = struct; end; % no parameter overloading

if isempty(param_dir) % if empty, use default
    param_dir = fullfile('communication','params');
end

comm_param = process_yaml(comm_str,param_dir,gen_param);
