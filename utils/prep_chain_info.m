function fc = prep_chain_info(sens,proc,comm,gen)
    %% Get processing shizzle
    E_proc = []; name_proc = cell(0); %init as empty at first run
    for p=1:length(proc) % for each processing chain
        E_proc(end+1) = proc{p}.cons.all;
        name_proc{end+1} = proc{p}.method;
    end
    %% summarize
    fc.E_sep = [sens.cons,E_proc,comm.cons];
    fc.E = sum(fc.E_sep); % vector containing energy per layer 
    fc.str = [{'Sensing'},name_proc(:)',{'Communication'}];
    
    fc.LT = energy2lifetime(fc.E,gen);
end

function LT = energy2lifetime(E,gen)
    LT = (gen.battery_joules/E)*gen.T/(60*60*24); %lifetime in days
end