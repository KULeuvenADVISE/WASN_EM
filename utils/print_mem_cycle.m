function print_mem_cycle(proc,gen)
disp('--- Memory storage and operations/second ---')
disp('* Clock cycles')
cycli_s = zeros(size(proc));
for p=1:length(proc)
    cycli_s(p) = sum(proc{p}.ops(:))/gen.T;
    disp([proc{p}.method ': ' num2str(cycli_s(p)) ' cycles/s']) 
end
disp(['Total: ' num2str(sum(cycli_s)) ' cycles/s'])

for m=1:gen.nr_mem
    disp(['* Memory ' num2str(m)])
    param = zeros(size(proc)); output = zeros(size(proc));
    for p=1:length(proc)
        param(p) = proc{p}.ms_p.all(m)/8/1024; % kB
        output(p) = proc{p}.ms_o.all(m)/8/1024; % kB
        disp([proc{p}.method ': ' num2str(param(p)) ' kB param. and ' num2str(output(p)) ' kB output']) 
    end
    disp(['Total: ' num2str(sum(param)) ' kB parameters and ' num2str(sum(output)) ' kB output']) 
end
end