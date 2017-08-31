% Area,MajorAxisLength,MinorAxisLength,Perimeter,Eccentricity,Extent,EquivDiameter,connectors,type,region,day (11)
cells = csvread('cells_3rd_try.dat');
% Area,MajorAxisLength,MinorAxisLength,Perimeter,Eccentricity,Extent,EquivDiameter,type,region,day (10)
fingers = csvread('fingers_3rd_try.dat');

ind_cell_type_adipo = find(cells(:,9)==1);
ind_cell_type_control = find(cells(:,9)==2);
ind_cell_type_myo = find(cells(:,9)==3);
ind_cell_type_osteo = find(cells(:,9)==4);

ind_finger_type_adipo = find(fingers(:,8)==1);
ind_finger_type_control = find(fingers(:,8)==2);
ind_finger_type_myo = find(fingers(:,8)==3);
ind_finger_type_osteo = find(fingers(:,8)==4);

%% linear classifier for cells
N = size(cells, 1);

C = [cells(:,1:8), cells(:,11)];

cell_types = cells(:,9);
% bi_class(ind_cell_type_adipo) = 2;
% bi_class(ind_cell_type_control) = 2;
% bi_class(ind_cell_type_myo) = 3;
% bi_class(ind_cell_type_osteo) = 2;
% cell_types = bi_class';

ldaClass = classify(C,C,cell_types,'linear');
bad = ldaClass ~= cell_types;
ldaResubErr = sum(bad) / N

adipo_bad = ldaClass(ind_cell_type_adipo) ~= 1;
adipoErr = sum(adipo_bad) / length(ind_cell_type_adipo)
control_bad = ldaClass(ind_cell_type_control) ~= 2;
controlErr = sum(control_bad) / length(ind_cell_type_control)
myo_bad = ldaClass(ind_cell_type_myo) ~= 3;
myoErr = sum(myo_bad) / length(ind_cell_type_myo)
osteo_bad = ldaClass(ind_cell_type_osteo) ~= 4;
osteoErr = sum(osteo_bad) / length(ind_cell_type_osteo)

s = RandStream('mt19937ar','seed',0);
RandStream.setDefaultStream(s);
cp = cvpartition(cell_types,'k',10);
ldaClassFun= @(xtrain,ytrain,xtest)(classify(xtest,xtrain,ytrain));
ldaCVErr  = crossval('mcr',C,cell_types,'predfun', ldaClassFun,'partition',cp)

%% linear classifier for fingers
N = size(fingers, 1);
F = [fingers(:,1:7), fingers(:,10)];
finger_types = fingers(:,8);

ldaClass = classify(F,F,finger_types,'linear');
bad = ldaClass ~= finger_types;
ldaResubErr = sum(bad) / N

adipo_bad = ldaClass(ind_finger_type_adipo) ~= 1;
adipoErr = sum(adipo_bad) / length(ind_finger_type_adipo)
control_bad = ldaClass(ind_finger_type_control) ~= 2;
controlErr = sum(control_bad) / length(ind_finger_type_control)
myo_bad = ldaClass(ind_finger_type_myo) ~= 3;
myoErr = sum(myo_bad) / length(ind_finger_type_myo)
osteo_bad = ldaClass(ind_finger_type_osteo) ~= 4;
osteoErr = sum(osteo_bad) / length(ind_finger_type_osteo)

s = RandStream('mt19937ar','seed',0);
RandStream.setDefaultStream(s);
cp = cvpartition(finger_types,'k',10);
ldaClassFun= @(xtrain,ytrain,xtest)(classify(xtest,xtrain,ytrain));
ldaCVErr  = crossval('mcr',F,finger_types,'predfun', ldaClassFun,'partition',cp)

%% tree classifier for cells
N = size(cells, 1);

cell_types = cells(:,9);
% bi_class(ind_cell_type_adipo) = 2;
% bi_class(ind_cell_type_control) = 2;
% bi_class(ind_cell_type_myo) = 3;
% bi_class(ind_cell_type_osteo) = 2;
% cell_types = bi_class';

cell_cats = {''};
for i=1:length(cell_types)
    if (cell_types(i) == 1) str_cat = 'a';
    elseif (cell_types(i) == 2) str_cat = 'c';
    elseif (cell_types(i) == 3) str_cat = 'm';
    elseif (cell_types(i) == 4) str_cat = 'o';
    end
    cell_cats = [cell_cats; str_cat];
end
cell_cats = cell_cats(2:length(cell_cats));
t = classregtree(C,cell_cats);

dtclass = t.eval(C);
bad = ~strcmp(dtclass,cell_cats);
dtResubErr = sum(bad) / N

adipo_bad = ~strcmp(dtclass(ind_cell_type_adipo),'a');
adipoErr = sum(adipo_bad) / length(ind_cell_type_adipo)
control_bad = ~strcmp(dtclass(ind_cell_type_control),'c');
controlErr = sum(control_bad) / length(ind_cell_type_control)
myo_bad = ~strcmp(dtclass(ind_cell_type_myo),'m');
myoErr = sum(myo_bad) / length(ind_cell_type_myo)
osteo_bad = ~strcmp(dtclass(ind_cell_type_osteo),'o');
osteoErr = sum(osteo_bad) / length(ind_cell_type_osteo)

%dtClassFun = @(xtrain,ytrain,xtest)(eval(classregtree(xtrain,ytrain),xtest));
%dtCVErr  = crossval('mcr',C,cell_types,'predfun', dtClassFun,'partition',cp)

resubcost = test(t,'resub');
[cost,secost,ntermnodes,bestlevel] = test(t,'cross',C,cell_cats);
plot(ntermnodes,cost,'b-', ntermnodes,resubcost,'r--')
figure(gcf);
xlabel('Number of terminal nodes');
ylabel('Cost (misclassification error)')
legend('Cross-validation','Resubstitution')

[mincost,minloc] = min(cost);
%cutoff = mincost + secost(minloc);
cutoff = mincost;
hold on
plot([0 20], [cutoff cutoff], 'k:')
plot(ntermnodes(bestlevel+1), cost(bestlevel+1), 'mo')
legend('Cross-validation','Resubstitution','Min + 1 std. err.','Best choice')
hold off

pt = prune(t,bestlevel);
view(pt)
cost(bestlevel+1)

figure;
plot(1:length(cost),cost)
title('Missclassification error')
xlabel('Number of terminal nodes')
ylabel('Cross-validation error')
saveas(gcf, 'MissClassErrorDecisionTree.png', 'png');
