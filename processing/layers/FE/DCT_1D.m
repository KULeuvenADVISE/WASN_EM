% ----------------------------------------------------------------------
%  DCT 1D behaviour model
%
%  Not described in document. DCT transform, typically used in a MFCC
%  feature extraction.
%  Used in:
%  G. Dekkers et al, “The SINS database for detection of daily activities in a home environment using an acoustic
%  sensor network,” in Proceedings of the Detection and Classification of Acoustic Scenes and Events 2017 Workshop (DCASE2017), Munich, Germany, November 2017, pp. 32–36.
%
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [output_shape, complexity, nr_parameters] = Activation(pp,gp,input_shape)
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
%   - class_name: DCT_1D
%     config:
%       coef: 14 %amount of DCT coefficients 
      
function [output_shape, complexity, nr_parameters] = DCT_1D(pp,gp,input_shape)
    % var inits
    output_shape = zeros(1,gp.nr_dimensions);
    complexity = zeros(1,gp.nr_arop);
    %nr_parameters = zeros(1,1);
    % output shape
    output_shape(1,[gp.chid gp.frameid]) = input_shape(1,[gp.chid gp.frameid]);
    output_shape(1,gp.featid) = pp.coef;
    % complexity
    complexity(1,gp.macid) = input_shape(1,gp.featid)*pp.coef; %matrix multipl
    complexity(1,:) = complexity(1,:)*output_shape(1,gp.frameid); %multpl by frames
    % number of parameters
    nr_parameters(1,:) = input_shape(1,gp.featid)*pp.coef; % dct matrix
end
