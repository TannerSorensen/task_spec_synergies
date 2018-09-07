function [new_vector, n_frm]= scaled_vector(t_scaled, old_vector, n_frm)

load t_params
new_vector_idx = [];
for i = 1:n_frm
    [a b] = min(abs(t_scaled-(i-1)*wag_frm/1000));
    new_vector_idx = [new_vector_idx round((b+4)/5)];
end   
new_vector = -ones(1, new_vector_idx(end));
new_vector(new_vector_idx) = old_vector;
while find(new_vector == -1)
    tmp1 = find(new_vector == -1);
    tmp2 = find(new_vector ~= -1);
    if tmp1(1) ~= 1
        beg_tmp = tmp2(max(find(tmp2 < tmp1(1))));
        if find(tmp2 > tmp1(1))
            end_tmp = tmp2(min(find(tmp2 > tmp1(1))));
            tmp3 = interp1([beg_tmp end_tmp], [new_vector(beg_tmp) new_vector(end_tmp)], [beg_tmp:end_tmp]);
            new_vector(beg_tmp+1:end_tmp-1) = tmp3(2:end-1);
        else
            new_vector(beg_tmp+1:end) = new_vector(beg_tmp);
        end
    else 
        end_tmp = tmp2(min(find(tmp2 > tmp1(1))));
        new_vector(1:end_tmp) = new_vector(end_tmp);
    end
end
n_frm = length(new_vector);