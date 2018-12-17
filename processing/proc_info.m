function [output_shape, complexity, nr_parameters] = proc_info(chain,gp,input_shape,verbose)
% ----------------------------------------------------------------------
%  Obtain output shape, complexity and number of parameters based on the
%  given chain. 
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: chain = proc_consumption(chain_str,input_shape,gen)
% Inputs:
% (1) chain             Chain str, refers to yaml file. E.g.  [str]
% (2) gp                general parameters, obtained using general/general_load_param.m
% (3) input_shape      	Input shape (given by previous chain). If no previous chain => use 'ADC'
% (4) verbose           print output bool [1/0]
% Outputs:
% (1) output_shape      output shape of each layer in the chain    
% (2) complexity        amount of clock cycli per layer in the chain  
% (3) nr_parameters     number of parameters for each layer in the chain 

% var inits
output_shape = zeros(size(chain,1),gp.nr_dimensions);
complexity = zeros(size(chain,1),gp.nr_arop);
nr_parameters = zeros(size(chain,1),1);
% process for each layer in the chain
for lid = 1:size(chain,1) %for every layer
    % get param
    layer_name = chain{lid,1}; % layer name
    pp = chain{lid,2}; % processing parameters
    % process param
    fh = str2func(layer_name); % get function handle
    [output_shape(lid,:), complexity(lid,:), nr_parameters(lid,:)] = fh(pp,gp,input_shape);
    % update input_shape
    input_shape = output_shape(lid,:);
end
% print
if verbose
    disp('--- IO shapes ---');
    disp([chain(:,1) mat2cell(output_shape,ones(size(output_shape,1),1),ones(size(output_shape,2),1))])
    disp('--- Complexity ---');
    heading = {'Layer','MAC','Add.','Prod.','Div.','Comp','e^x','log'};
    disp([heading; [[chain(:,1);{'Total'}] [mat2cell(complexity,ones(size(complexity,1),1),ones(size(complexity,2),1));    mat2cell(sum(complexity,1),1,ones(size(complexity,2),1))]]])
    disp('--- Parameters ---');
    disp([[chain(:,1);{'Total'}] [mat2cell(nr_parameters,ones(size(nr_parameters,1),1),ones(size(nr_parameters,2),1));    mat2cell(sum(nr_parameters),1,ones(size(nr_parameters,2),1))]])
end
end