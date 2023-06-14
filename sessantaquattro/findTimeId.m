function [id,diff] = findTimeId(timemat, t)
% return the index of time that is closed to t, diff equals to the timemat(id)-t

id_1 = find(timemat>t,1);
tm_temp = timemat(id_1-1:id_1);
tm_temp = split(tm_temp,'.');
tm_temp = tm_temp(:,2);
tm_temp_ms = str2double(tm_temp);

t = split(t,'.');
t = t(2);
t_ms = str2double(t);

t_diff = tm_temp_ms  -  t_ms;
abs_diff = abs(t_diff);
if t_diff(2) == min(abs_diff)
    id = id_1;
    diff = t_diff(2);
else
    id = id_1-1;
    diff = t_diff(1);
end
end
