function [usert, userber, usermag, userpha] = getInfo2(user)

usert = table2array(user(:,1));
userber = table2array(user(:,3));
usermag = table2array(user(:,4:2:52));
userpha = table2array(user(:,5:2:53));
