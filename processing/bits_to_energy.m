function [con,ops_en, ms_o_en, ms_p_en, ma_en] = bits_to_energy(ma,ms_o,ms_p,ops,gen)
% ----------------------------------------------------------------------
%  Function which converts stored to be stored and memory access to an
%  energy value 
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [con,ops_en, ms_o_en, ms_p_en, ma_en] = bits_to_energy(ma,ms_o,ms_p,ops,gen)
% Inputs:
% (1) ma            Total memory accesses for a particular memory, acquired by memo_acc_stor.m
% (2) ms_o          Total storage (outputs) for a particular memory, acquired by memo_acc_stor.m
% (3) ms_p          Total storage (parameters) for a particular memory, acquired by memo_acc_stor.m
% (4) ops           Total operations for a particular memory, acquired by feature_complexity.m
% (5) gen           general parameters, acquired by general_param.m [struct]
% Outputs:
% (1) con           Total energy consumption [mJ]
% (2) ops_en        Energy per operation per layer [mJ]
% (3) ms_o_en       Energy consumed by memory storage of output values per layer in the processing chain [mJ]
% (4) ms_p_en       Energy consumed by memory storage of parameter values per layer in the processing chain [mJ]
% (5) ma_en         Energy consumed by memory accesses per layer in the processing chain [mJ] 

    ops_en = ops.*repmat(gen.c,size(ops,1),1)*gen.Eop; %[mJ] - eq. 11 - due to operations
    ms_o_en = ms_o.sep.*repmat(gen.Ems,size(ms_o,1),1)*gen.T; % [mJ] - eq. 11 - due to storage of intermediate values
    ms_p_en = ms_p.sep.*repmat(gen.Ems,size(ms_p,1),1)*gen.T; % [mJ] - eq. 11 - due to storage of parameters
    ma_en = ma.sep.*repmat(gen.Ema,size(ma,1),1); % [mJ] - eq. 11 - due to memory accesses
    con = sum(ma_en(:))+sum(ms_o_en(:))+sum(ms_p_en(:))+sum(ops_en(:)); % [mJ] - combine
end