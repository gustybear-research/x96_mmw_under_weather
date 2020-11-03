clc
clear
close all

load exData.mat % CSI of RX is Bcsi
load('arrayResponseAllnew.mat'); % antenna gain: row: direction, column: antenna mode

% resort mode index according to experiment
[tempind, ind] = max(arrayResponseAll);
[tempind, ind1] = sort(ind);
arrayResponseAll = arrayResponseAll(:,ind1);

figure
polar((0:pi/180:2*pi)',arrayResponseAll(:,45))
title('radiation pattern')

%% AoD ground truth
arrayResponseSet = arrayResponseAll;
arrayResponseSet =  arrayResponseSet';

% a0 = arrayResponseSet\Bcsi;
% AoD estimation code
alpha0 = 0.6;
D = 361;
cvx_begin quiet
variable a0(D) complex
minimize(norm(arrayResponseSet * a0 - Bcsi, 2)  + alpha0 * norm(a0, 1) + (1-alpha0)*norm(a0, 2))
cvx_end

%% AoD estimation
seed = rng;
% save('seedForEx.mat','seed')
numSamples = 40;
modeSet = randperm(361,numSamples);
hSet = Bcsi(modeSet);

arrayResponseSet = arrayResponseAll(:,modeSet);
arrayResponseSet = arrayResponseSet';

% AoD estimation code
% D = 361;
% cvx_begin quiet
% variable a(D) complex
% minimize(norm(a, 1))
% subject to
% arrayResponseSet * a == hSet
% cvx_end

alpha = 0.6;
D = 361;
cvx_begin quiet
variable a(D) complex
minimize(norm(arrayResponseSet * a - hSet, 2)  + alpha * norm(a, 1) + (1-alpha)*norm(a, 2))
cvx_end

figure
plot(abs(a0))
hold on
plot(abs(a))
title('AoD distribution')
legend('ground truth','estimation')

figure
plot(aB,abs(Bcsi))
hold on
% plot(aB,abs(arrayResponseAll.'*a0))
% hold on
plot(aB,abs(arrayResponseAll.'*a)) % predicted CSI
legend({'measured','predicted'},'FontSize',12)
xlim([aB(1) aB(end)])
xlabel('Antenna mode')
ylabel('Magnitude of CSI')
set(gca,'FontSize',12)