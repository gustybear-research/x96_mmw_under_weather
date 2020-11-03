function [userber, usermag, userpha] = getInfo(user)

userber = table2array(user(:,4));
usermag = table2array(user(:,5:2:53));
userpha = table2array(user(:,6:2:54));
