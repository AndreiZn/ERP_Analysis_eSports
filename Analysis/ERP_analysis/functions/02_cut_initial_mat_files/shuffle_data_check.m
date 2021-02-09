gid_true = y(36,:);
gid_r = y_r(36,:);

gid_trig = find(gid_true>=1); 
gid_f = gid_trig(1);
gid_l = gid_trig(end);

gid_true(1:gid_f-1) = 0;
gid_true(gid_l+1:end) = 0;
gid_r(1:gid_f-1) = 0;
gid_r(gid_l+1:end) = 0;

trig_begin = find(diff(gid_true) > 0) + 1;
trig_end = find(diff(gid_true) < 0) + 1;

s = 0; k = 0;
for idx=1:200
    gid_true_cur = gid_true(trig_begin(idx));
    gid_r_cur = gid_r(trig_begin(idx));
    if gid_r_cur >=8 && gid_true_cur >= 8
        s = s + 1;
    end    
    if gid_r_cur >=8 && gid_true_cur < 8
        k = k + 1;
    end
end

disp(s)
disp(k)