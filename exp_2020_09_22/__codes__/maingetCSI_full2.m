clc
clear
close all

%% **** load
% fileB = './mmWave_28GHz_TX00_RX10_115cm/BER_CSI_B_20_09_15_16_38.csv';
% fileB = './mmWave_28GHz_TX00_RX10_115cm_Blockage/BER_CSI_B_20_09_15_16_46.csv';
% fileB = './mmWave_28GHz_TX00_RX10_115cm_NoBlockage/BER_CSI_B_20_09_15_16_48.csv';
% fileB = './mmWave_28GHz_TX05_RX10_115cm/BER_CSI_B_20_09_15_16_37.csv';
% fileB = './mmWave_28GHz_TX10_RX10_115cm/BER_CSI_B_20_09_15_16_33.csv';
fileB = './mmWave_28GHz_TX15_RX10_115cm/BER_CSI_B_20_09_15_16_30.csv';

name_ind = '_mmWave_28GHz_TX15_RX10_115cm';

B = readtable(fileB);

%% get data
[Bt, Bber, Bmag, Bpha] = getInfo2(B);
Bt = Bt(:,1) - Bt(1,1); 

%% get CSI for data set c
c = 1;
Bcsi = Bmag .* exp(1i.*Bpha);

for ii = 1:25
    if ii == 25
        Bcsi(:,ii) = 1 ./ Bcsi(:,ii);
    else
        Bcsi(:,ii) = 1 ./ ((Bcsi(:,ii+1)-Bcsi(:,ii))/6 * c + Bcsi(:,ii));
    end
end

figure
subplot(2,1,1);
plot(abs(Bcsi(:,end)))
title('mag of CSI')
ylim([0 1])
subplot(2,1,2);
plot(angle(Bcsi(:,end)))
title('pha of CSI')

%%
% make aB to [1,361]
aB = -45:90/(length(Bber)-1):45;

%%
figure
subplot(2,1,1)
plot(aB,abs(Bcsi(:,end)),'k','LineWidth',1.2)
xlabel('Antenna mode')
ylabel('Magnitude of CSI')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
xlim([-45 45])
subplot(2,1,2)
plot(aB,angle(Bcsi(:,end)),'k','LineWidth',1.2)
xlabel('Antenna mode')
ylabel('Phase of CSI')
set(gca,'FontSize',12,'Color',[245, 245, 245]/255)
xlim([-45 45])
fig = get(groot,'CurrentFigure');
fig.PaperPositionMode = 'auto';
fig.Color = [245, 245, 245]/255;
fig.InvertHardcopy = 'off';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
name5 = ['./figures/CSI' name_ind '.eps'];
print(fig,'-deps', name5)

%% **** save
% save('./extractedData/data9.mat','Bcsi','aB')
% disp('********** saved **********')