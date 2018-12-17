% ----------------------------------------------------------------------
%  Aggregation behaviour model
%
%  Not described in document. Refers to aggregating features over time.
%  Used in:
%  G. Dekkers et al, “The SINS database for detection of daily activities in a home environment using an acoustic
%  sensor network,” in Proceedings of the Detection and Classification of Acoustic Scenes and Events 2017 Workshop (DCASE2017), Munich, Germany, November 2017, pp. 32–36.
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Aggregation(pp,gp,input_shape)
% Inputs:
% (1) pp                output shape of the layer given an input shape and parameters
% (2) gp                complexity of the layer given an input shape and parameters
% (3) input_shape       number of parameters of the layer given an input shape and parameters
% Outputs:
% (1) output_shape      output shape of the layer given an input shape and parameters
% (2) complexity        complexity of the layer given an input shape and parameters
% (3) nr_parameters     number of parameters of the layer given an input shape and parameters
%
% Usage example (chain):
%   - class_name: Aggregation
%     config:
%       type: [mean,std] % use mean and std as output / other options could be [mean], [std]

function [output_shape, complexity, nr_parameters] = Aggregation(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,[gp.chid gp.featid gp.frameid]) = [input_shape(1,gp.chid) input_shape(1,gp.featid)*length(pp.type) 1];
    % complexity
    for agg=pp.type
        switch agg{1}
            case 'mean'
                complexity(1,gp.addid) = complexity(1,gp.addid) + input_shape(1,gp.featid)*input_shape(1,gp.frameid); %a+b+c
                complexity(1,gp.divid) = complexity(1,gp.divid) + 1; %1/N
            case 'std'
                complexity(1,gp.addid) = complexity(1,gp.addid) + input_shape(1,gp.featid)*input_shape(1,gp.frameid); %substract mean from values
                complexity(1,gp.multid) = complexity(1,gp.multid) + input_shape(1,gp.featid)*input_shape(1,gp.frameid); %square
        end
    end
    % number of parameters
    % /
end

