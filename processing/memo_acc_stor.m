function [proc_ma, proc_ms_o, proc_ms_p] = memo_acc_stor(shapes,param,compl,chain,prevchain,gen,verbose)
% ----------------------------------------------------------------------
%  Function which converts (for each memory seperately):
%   (a) # parameters to # bits to store 
%   (b) given the amount of parameters/operations the amount of memory
%   accesses 
%  Author: Gert Dekkers, KU Leuven
% ----------------------------------------------------------------------
% Syntaxis: [proc_ma, proc_ms_o, proc_ms_p] = memo_acc_stor(shapes,param,compl,chain,gen)
% Inputs:
% (1) shapes        Output shapes of each layer in processing chain, acquired by either feature_io_shape.m or model_io_shape.m
% (2) param         Nr. of parameters per layer, acquired by either feature_nrparameters.m or model_nrparameters.m
% (3) compl         Complexity per layer, acquired by either feature_nrparameters.m or model_nrparameters.m
% (4) chain         Chain parameters per layer, acquired by either feature_loadparam.m or model_loadparam.m
% (5) gen           general parameters, acquired by general_param.m [struct]
% Outputs:
% (1) proc_ma       Total memory accesses 
% (2) proc_ms_o     Total memory storage for output of each layer
% (3) proc_ms_p     Total memory storage for parameters of each layer

% Process
proc_ma.sep = zeros(size(chain,1),gen.nr_mem);
proc_ms_o.sep = zeros(size(chain,1),gen.nr_mem);
proc_ms_p.sep = zeros(size(chain,1),gen.nr_mem);
for lid = 1:size(chain,1) %for every layer
    % get settings
    tmp = chain{lid,3};
    lid2 = lid; ready = 0;
    while ready==0 % get memory index of where the last memory is reserved
        tmpprev = chain{lid2,3};
        lid2 = lid2-1;
        if tmpprev.output_save, ready = 1; tmp.output = tmpprev.output; end;
        if lid2==0 && ready == 0 % if no mem specification in this chain
            lid3 = size(prevchain,1); ready2 = 0;
            while ready2==0 % get memory index of where the last memory in the previous chain
                tmpprev = prevchain{lid3,3};
                lid3 = lid3-1;
                if tmpprev.output_save, ready2 = 1; ready = 1; tmp.output = tmpprev.output; end;
                if lid3==0 && ready2 == 0 % if no mem specification in this chain
                    error('Nothing is saved in these layers. Fix');
                end
            end
        elseif lid2==0 && ready == 0 && ~isempty(prevchain)
            error('Nothing is saved in these layers. Fix');
        end;
    end
    % process mem storage
    proc_ms_o.sep(lid,tmp.output) = prod(shapes(lid,:)) * tmp.output_save * gen.S; 
    proc_ms_p.sep(lid,tmp.parameters) = param(lid,:) * gen.S; 
    % process mem accesses
    proc_ma.sep(lid,tmp.output) = sum(compl(lid,:).*min(gen.memacc_c,repmat(tmp.output_acc,1,length(gen.memacc_c)))) * gen.S; % output
    proc_ma.sep(lid,tmp.parameters) = proc_ma.sep(lid,tmp.parameters) + sum(compl(lid,:).*max(gen.memacc_c - tmp.output_acc,0)) * gen.S; % output
end
proc_ms_o.all = sum(proc_ms_o.sep,1);
proc_ms_p.all = sum(proc_ms_p.sep,1);
proc_ma.all = sum(proc_ma.sep,1);

% Output
if verbose
    disp('--- Memory storage ---');
    heading{1} = 'Layer'; for k=2:gen.nr_mem+1, heading{k} = ['Mem. ' num2str(k-1) ' (kB)']; end
    vals = (proc_ms_o.sep+proc_ms_p.sep)/(8*1024);
    disp([heading; [[chain(:,1);{'Total'}] [mat2cell(vals,ones(size(vals,1),1),ones(size(vals,2),1));    mat2cell(sum(vals,1),1,ones(size(vals,2),1))]]])
    disp('--- Memory accesses ---');
    heading{1} = 'Layer'; for k=2:gen.nr_mem+1, heading{k} = ['Mem. ' num2str(k-1) '(bits)']; end
    vals = proc_ma.sep;
    disp([heading; [[chain(:,1);{'Total'}] [mat2cell(vals,ones(size(vals,1),1),ones(size(vals,2),1));    mat2cell(sum(vals,1),1,ones(size(vals,2),1))]]])
end
end