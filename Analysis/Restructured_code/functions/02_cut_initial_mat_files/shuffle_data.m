groupid = y(36, :);

non_target = ones(1,160); target = 8*ones(1,40);
gid = [non_target, target];
idx = randperm(200);

gid_r = gid(idx);

gid_trig = find(groupid>=1); 
gid_f = gid_trig(1);
gid_l = gid_trig(end);
groupid(1:gid_f-1) = 0;
groupid(gid_l+1:end) = 0;
trig_begin = find(diff(groupid) > 0) + 1;
trig_end = find(diff(groupid) < 0) + 1;

groupid_new = groupid;

for idx=1:200
    idx_to_use = trig_begin(idx):trig_end(idx);
    num_points = numel(idx_to_use);
    groupid_new(idx_to_use) = gid_r(idx)*ones(1,num_points);
end

% figure()
% subplot(2,1,1)
% plot(groupid)
% subplot(2,1,2)
% plot(groupid_new)

y(36,:) = groupid_new;
