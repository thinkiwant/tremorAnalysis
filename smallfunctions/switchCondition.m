function data = switchCondition(raw_data, id, condition_to_switch)
% id denotes the column id of condition in raw_data. 

null_condition = -1;
condition1 = condition_to_switch(1);
condition2 = condition_to_switch(2);
data = raw_data;
data(data(:, id) == condition1, id)= null_condition;
data(data(:, id) == condition2, id)= condition1;
data(data(:, id) == null_condition, id)= condition2;
end