function print_chain_info(fc)
    disp('--- Energy consumption and lifetime ---')
    E_str = 'Energy consumption'; E_norm_str = 'Relative energy consumption';
    for p=1:length(fc.str) 
        if p==1, E_str = [E_str ' > ']; E_norm_str = [E_norm_str ' > ']; else E_str = [E_str ' - ']; E_norm_str = [E_norm_str ' - ']; end; 
        E_str = [E_str fc.str{p} ': ', num2str(fc.E_sep(p)) ' mJ '];
        E_norm_str = [E_norm_str fc.str{p}  ': ', num2str(fc.E_sep(p)/fc.E) '% '];
    end
    disp(E_str)
    disp(E_norm_str)
    disp(['Lifetime is ' num2str(fc.LT) ' days']);
end