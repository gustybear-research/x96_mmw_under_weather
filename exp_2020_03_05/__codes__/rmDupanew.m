function [a, csi, I] = rmDupanew(a0, csi0)
a = [];
ind = [];
for ii = 2:length(a0)
    jj = ii-1;
    if (a0(jj)-a0(ii)) >= 350
        ind = [ind;jj];
    end
end
% ind = find(a0==max(a0));
numEst = length(ind)+1;
if ind(end) == length(a0)
    numEst = length(ind);
end
csi = zeros(360,numEst);
atemp = zeros(360,numEst);
for kk = 2:numEst    
    if kk == 1
        s1 = 1;
        s2 = ind(kk);
    elseif kk == numEst && numEst > length(ind)
        s2 = length(a0);
        s1 = ind(kk-1)+1;
    else
        s1 = ind(kk-1)+1;
        s2 = ind(kk);
    end
    row = a0(s1:s2)+1; % make angle in range {1,...,360}
    a = [a;unique(row)];
    tempcsi0 = csi0(s1:s2);
    ii = 1;
    flag = 0;
    while ii<=length(row)
        if ii<length(row)
            jj = ii+1;
            while row(jj) == row(ii)
                jj = jj+1;
                if jj==length(row)
                    jj = jj+1;
                    break
                end
                flag = 1;
            end
            if flag
                csi1 = mean(tempcsi0(ii:jj-1));
                csi(row(ii),kk) = csi1;
            else
                csi(row(ii),kk) =  tempcsi0(ii);
            end
            ii = jj;
        else
            csi(row(ii),kk) = tempcsi0(ii);
            ii = ii+1;
        end
        atemp(unique(row),kk) = unique(row);
    end
end

csitemp = csi;
csi = reshape(csi,[],1);
csi(csi==0) = [];

% figure
% for ii = 1:numEst
%     ind1 = find(atemp(:,ii)~=0);
%     plot(atemp(ind1,ii),abs(csitemp(ind1,ii)))
%     hold on
% end
% figure
% for ii = 1:numEst
%     ind1 = find(atemp(:,ii)~=0);
%     plot(atemp(ind1,ii),angle(csitemp(ind1,ii)))
%     hold on
% end

ind = [];
for ii = 2:length(a)
    jj = ii-1;
    if (a(jj)-a(ii)) >= 350
        ind = [ind;jj];
    end
end

% I = ind(1);
I = ind;