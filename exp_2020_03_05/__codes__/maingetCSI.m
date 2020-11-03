clc
clear
close all

fileB = 'BER_CSI_B_20_01_16_21_49.csv'; % 15_15_36
fileE1 = 'BER_CSI_E1_20_01_16_21_49.csv';
fileE2 = 'BER_CSI_E2_20_01_16_21_49.csv';

B = readtable(fileB);
E1 = readtable(fileE1);
E2 = readtable(fileE2);

%% get data
[Bber, Bmag, Bpha] = getInfo(B);
[E1ber, E1mag, E1pha] = getInfo(E1);
[E2ber, E2mag, E2pha] = getInfo(E2);

aB = table2array(B(:,2));
aE1 = table2array(E1(:,2));
aE2 = table2array(E2(:,2));

%% get CSI for data set c
c = 1;
Bcsi = Bmag .* exp(1i.*Bpha);
E1csi = E1mag .* exp(1i.*E1pha);
E2csi = E2mag .* exp(1i.*E2pha);

for ii = 1:25
    if ii == 25
        Bcsi(:,ii) = 1 ./ Bcsi(:,ii);
        E1csi(:,ii) = 1 ./ E1csi(:,ii);
        E2csi(:,ii) = 1 ./ E2csi(:,ii);
    else
        Bcsi(:,ii) = 1 ./ ((Bcsi(:,ii+1)-Bcsi(:,ii))/6 * c + Bcsi(:,ii));
        E1csi(:,ii) = 1 ./ ((E1csi(:,ii+1)-E1csi(:,ii))/6 * c + E1csi(:,ii));
        E2csi(:,ii) = 1 ./ ((E2csi(:,ii+1)-E2csi(:,ii))/6 * c + E2csi(:,ii));
    end
end

figure
subplot(3,1,1);
plot(abs(Bcsi))
title('mag of CSI (B, E1, E2)')
subplot(3,1,2);
plot(abs(E1csi))
subplot(3,1,3);
plot(abs(E2csi))

figure
subplot(3,1,1);
plot(angle(Bcsi))
yyaxis right
plot(table2array(B(:,2)))
title('pha of CSI (B, E1, E2)')
subplot(3,1,2);
plot(angle(E1csi))
yyaxis right
plot(table2array(E1(:,2)))
subplot(3,1,3);
plot(angle(E2csi))
yyaxis right
plot(table2array(E2(:,2)))

%% sort & average with Alice's angle
Bcsi0 = Bcsi;
E1csi0 = E1csi;
E2csi0 = E2csi;
numSub = size(Bcsi0,2);
clear Bcsi E1csi E2csi
aaB = aB;
aaE1 = aE1;
aaE2 = aE2;

% separate a given subcarrier from multiple measurements
for sub = 1:numSub
    [aB, Bcsi(:,sub), indB] = rmDupanew(aaB, Bcsi0(:,sub)); % degree:[0, 360]
    [aE1, E1csi(:,sub), indE1] = rmDupanew(aaE1, E1csi0(:,sub));
    [aE2, E2csi(:,sub), indE2] = rmDupanew(aaE2, E2csi0(:,sub));
end

%% check
sub = 1;
figure
plot(aB(1:indB(1)),abs(Bcsi(1:indB(1),sub)))
hold on
for ii = 2:length(indB)
    s1 = indB(ii-1)+1;
    s2 = indB(ii);
    plot(aB(s1:s2),abs(Bcsi(s1:s2,sub)))
    hold on
end
title('mag of CSI (subchannel 1)')

%% average CSI over all subcarriers
Bcsi = (mean(Bcsi(1:indB(length(indB)),:).')).';
aB = aB(1:indB(length(indB)));

E1csi = (mean(E1csi(1:indE1(length(indE1)),:).')).';
aE1 = aE1(1:indE1(length(indE1)));
E2csi = (mean(E2csi(1:indE2(length(indE2)),:).')).';
aE2 = aE2(1:indE2(length(indE2)));

%% average CSI with cycles
tempB = zeros(361,length(indB));
tempB(aB(1:indB(1)),1) = Bcsi(1:indB(1));
for ii = 2:length(indB)
    s1 = indB(ii-1)+1;
    s2 = indB(ii);
    tempB(aB(s1:s2),ii) = Bcsi(s1:s2);
    hold on
end

tempE1 = zeros(361,length(indE1));
tempE1(aE1(1:indE1(1)),1) = E1csi(1:indE1(1));
for ii = 2:length(indE1)
    s1 = indE1(ii-1)+1;
    s2 = indE1(ii);
    tempE1(aE1(s1:s2),ii) = E1csi(s1:s2);
    hold on
end

tempE2 = zeros(361,length(indE2));
tempE2(aE2(1:indE2(1)),1) = E2csi(1:indE2(1));
for ii = 2:length(indE2)
    s1 = indE2(ii-1)+1;
    s2 = indE2(ii);
    tempE2(aE2(s1:s2),ii) = E2csi(s1:s2);
    hold on
end

BBcsi = zeros(361,1);
for ii = 1:size(tempB,1)
    temp = tempB(ii,:);
    temp1 = find(temp==0);
    if length(temp1)<size(tempB,2)
        BBcsi(ii) = sum(temp)/(size(tempB,2)-length(temp1));
    end
end

EE1csi = zeros(361,1);
for ii = 1:size(tempE1,1)
    temp = tempE1(ii,:);
    temp1 = find(temp==0);
    if length(temp1)<size(tempE1,2)
        EE1csi(ii) = sum(temp)/(size(tempE1,2)-length(temp1));
    end
end
        
EE2csi = zeros(361,1);
for ii = 1:size(tempE2,1)
    temp = tempE2(ii,:);
    temp1 = find(temp==0);
    if length(temp1)<size(tempE2,2)
        EE2csi(ii) = sum(temp)/(size(tempE2,2)-length(temp1));
    end
end

aB = find(BBcsi~=0);
Bcsi = BBcsi(aB);
if max(aB)~=361
    aB = [aB;361];
    Bcsi = [Bcsi;Bcsi(end)];
end

aE1 = find(EE1csi~=0);
E1csi = EE1csi(aE1);
if max(aE1)~=361
    aE1 = [aE1;361];
    E1csi = [E1csi;E1csi(end)];
end

aE2 = find(EE2csi~=0);
E2csi = EE2csi(aE2);
if max(aE2)~=361
    aE2 = [aE2;361];
    E2csi = [E2csi;E2csi(end)];
end

%% interplot
aB = aB-1;
aE1 = aE1-1;
aE2 = aE2-1;

aaB = (0:1:360)';
aaB = setdiff(aaB,aB);
BBcsi = interp1(aB, Bcsi, aaB);

aB = [aB;aaB];
Bcsi = [Bcsi;BBcsi];
[aB, ind] = sort(aB);
Bcsi = Bcsi(ind);

aaE1 = (0:1:360)';
aaE1 = setdiff(aaE1,aE1);
E1E1csi = interp1(aE1, E1csi, aaE1);

aE1 = [aE1;aaE1];
E1csi = [E1csi;E1E1csi];
[aE1, ind] = sort(aE1);
E1csi = E1csi(ind);

aaE2 = (0:1:360)';
aaE2 = setdiff(aaE2,aE2);
E2E2csi = interp1(aE2, E2csi, aaE2);

aE2 = [aE2;aaE2];
E2csi = [E2csi;E2E2csi];
[aE2, ind] = sort(aE2);
E2csi = E2csi(ind);

figure
plot(aB,abs(Bcsi))
title('mag of averaged CSI')
figure
plot(aB,angle(Bcsi))
title('pha of averaged CSI')

save('exData.mat','Bcsi','aB','E1csi','aE1','E2csi','aE2')