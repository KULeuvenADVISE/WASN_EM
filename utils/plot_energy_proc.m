function plot_energy_proc(proc)
    for p=1:length(proc)
        strs = proc{p}.conf(:,1);
        en = proc{p}.cons;
        % Plot extended energy consumption of feat
        y = [sum(en.op,2) sum(en.ma,2) sum(en.ms_p,2) sum(en.ms_o,2)];
        if size(strs,1)==1, y = [y; nan(1,4)]; end
        figure; bar(y,'stacked'); 
        legend('Operations','Memory accesses','Memory storage (param.)', 'Memory storage (output)');
        set(gca,'xtick',1:size(strs,1),'xticklabel',strs); xtickangle(45);
        title('Energy consumption per layer in processing chain'); xlabel('Layers'); ylabel('Energy consumption [mJ]'); 
    end
end