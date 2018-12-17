% ----------------------------------------------------------------------
%  Mel scale filterbank behaviour model
%
%  Section 4.1.2
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Melscale_filterbank(pp,gp,input_shape)
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
%   - class_name: Melscale_filterbank
%     config:
%       melbands: 26 %amount of used filterbanks

function [output_shape, complexity, nr_parameters] = Melscale_filterbank(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    %nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,[gp.chid gp.frameid]) = input_shape(1,[gp.chid gp.frameid]);
    output_shape(1,gp.featid) = pp.melbands;
    % complexity
    complexity(1,gp.macid) = input_shape(1,gp.featid)*pp.melbands; %matrix multipl, could be made sparser
    complexity(1,:) = complexity(1,:)*output_shape(1,gp.frameid); %multpl by frames
    % number of parameters
    nr_parameters = input_shape(1,gp.featid)*pp.melbands; % mel matrix
end

