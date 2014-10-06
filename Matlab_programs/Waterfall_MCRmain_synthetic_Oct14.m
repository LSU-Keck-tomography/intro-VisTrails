% Waterfall_MCRmain_synthetic_Oct14.m
%
%
clc; clear;
cd('/Users/les/Dropbox/Papers/Battery_manuscript/PCA_literature/expt_data_cropped/');


% Jinghua's comment Oct 6, 2014
% Les's comment after Jinghua's of Oct 6, 2014
% more comments by les


info = h5info([pwd,'/../synthetic41_allData.h5']);  
info.Datasets.Name;
allData = h5read([pwd,'/../synthetic41_allData.h5'],'/allData');  
info = h5info([pwd,'/../synthetic41_sTranspose.h5']);  
info.Datasets.Name;
sTranspose = h5read([pwd,'/../synthetic41_sTranspose.h5'],'/sTranspose');  
info = h5info([pwd,'/../synthetic_TOF_SOC_axis.h5']);  
info.Datasets.Name;
xTOF = h5read([pwd,'/../synthetic_TOF_SOC_axis.h5'],'/xTOF');  
xSOC = h5read([pwd,'/../synthetic_TOF_SOC_axis.h5'],'/xSOC');  

index=3500;
xTOF = xTOF(1:10:index);
allData=allData(1:10:index,:);
sTranspose=sTranspose(1:10:index,:);
index=length(xSOC)
xSOC = xSOC(1:3:index);
allData=allData(:,1:3:index);
allData = 100*allData/max(max(allData));
sTranspose = 100*sTranspose/max(max(sTranspose));
size(xTOF)
size(allData)
size(xSOC)

% h1=figure(1); set(h1,'Color',[1,1,1],'Position',[45 3 988 699]); clf
% h2=waterfall(xTOF,xSOC,allData')
% 	set(gca, 'YDir','rev');
%     axis([4 22, 0, 100, 0 50])
%     set(gca,'Box','on','ZTick',[],'FontSize',18,'FontName','Times');
%     h3 = xlabel('d-spacing/\AA','interpreter','latex','FontSize',18,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',14,'Position',position+[0,1.5,0]);
%     h3 = ylabel('state-of-charge','FontSize',18,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',-26,'Position',position+[0.2,0.8,0])
%     h3 = title('synthetic battery','FontSize',24,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',0,'Position',position+[0.0,0,-5],'EdgeColor','w')
% %    print -dpdf 'Synth_waterfall_allData.pdf' -f1
%     


h1=figure(2); set(h1,'Color',[1,1,1],'Position',[45 3 988 699]); clf
h2=waterfall(xTOF,1:7,sTranspose')
    axis([4, 22, 0.5, 7.5, 0 50])
    set(gca,'Box','on','ZTick',[],'FontSize',18,'FontName','Times');
	strXTickLabels = {'$5$','$10$','$15$','$20$'}
 	strYTickLabels = {'$Cu+Al$','$LiCoO_2$','$Li_{0.75}CoO_2$','$Li_{0.5}CoO2$','$LiC_6$','$LiC_{12}$','$C_6$'}
%    strYTickLabel = {'$\overrightarrow{Cu+Al}$','$\overrightarrow{LiCoO_2}$',...
%        '$\overrightarrow{Li_{0.75}CoO_2}$','$\overrightarrow{Li_{0.5}CoO_2}$',...
%       '$\overrightarrow{LiC_6}$','$\overrightarrow{LiC_{12}}$','$\overrightarrow{C_6}$'}
    [hx,hy] = format_ticks(gca,strXTickLabels,strYTickLabels,[],[0:7]);
%     ,[],[],[],[],0.06,'FontSize',14,'FontWeight','Bold');

    h3 = xlabel('d-spacing/\AA','interpreter','latex','FontSize',18,'FontName','Times');
    position = get(h3, 'Position');
	set(h3,'Rotation',14,'Position',position+[0,1.5,0]);
    h3 = ylabel('state-of-charge','FontSize',18,'FontName','Times');
    position = get(h3, 'Position');
	set(h3,'Rotation',-26,'Position',position+[0.2,0.8,0])
    h3 = title('synthetic battery: $S^T$','interpreter','latex','FontSize',24,'FontName','Times');
    position = get(h3, 'Position');
	set(h3,'Rotation',0,'Position',position+[0.0,0,-5],'EdgeColor','w')
%    print -dpdf 'Synth_waterfall_sTranspose.pdf' -f1
    



break;
% xDspace = h5read([pwd,'/exptfreshallData_v2p092.h5'],'/xDspace');  % need xDspace
% xSOCfresh = h5read([pwd,'/exptfreshallData_v2p092.h5'],'/xSOCfresh');   % need xSOCfresh
% 
% index = 1; % fresh
% filenameMAT_Concentration = dir('copt*.mat');  
% filenameMAT_Spectra = dir('sopt*.mat');  
% 
% filenameMAT_Concentration(index).name
% filenameMAT_Spectra(index).name
% 
% concentration = getfield(load(filenameMAT_Concentration(index).name),'sopt');
% size(concentration)
% spectra = getfield(load(filenameMAT_Spectra(index).name),'copt');
% size(spectra)
% 
% concentration = getfield(load(filenameMAT_Concentration(1).name),'sopt');
% size(concentration)
% spectra = getfield(load(filenameMAT_Spectra(1).name),'copt');
% size(spectra)
% 
% concentration = 100 * concentration/max(sum(concentration))
% 
% h1=figure(3); set(h1,'Color',[1,1,1]); clf
% h2=plot(xSOCfresh,concentration')
% 	set(gca, 'XDir','rev');
%     axis([0  100.0000   -0.00002   100 ])
% 	set(h2(1),'LineWidth',2);
%     set(h2(2),'LineWidth',2);
%     set(h2(3),'LineWidth',2);
%     set(h2(4),'LineWidth',2);
%     set(h2(5),'LineWidth',2);
%     set(h2(6),'LineWidth',2);
%     set(h2(7),'LineWidth',2);
%     set(gca,'FontSize',14,'FontName','Times');
% h3 = xlabel('state-of-charge/\%','interpreter','latex','FontSize',18,'FontName','Times');
% h3 = ylabel('score/\%','interpreter','latex','FontSize',18,'FontName','Times');
% h3 = title('fresh battery','FontSize',24,'FontName','Times');
% print -dpdf 'Fresh_lineplot_MCR-concentration.pdf' -f3
% 

% 
% spectra = [spectra(1:3,:);  zeros(1,7); spectra(4:length(spectra),:)];
% spectra = [spectra(1:23,:); zeros(1,7); spectra(24:length(spectra),:)];
% spectra = [spectra(1:24,:);zeros(1,7);spectra(25:length(spectra),:)];
% spectra = [spectra(1:40,:);zeros(1,7);spectra(41:length(spectra),:)];
% spectra = [spectra(1:74,:);zeros(1,7);spectra(75:length(spectra),:)];
% spectra = [spectra(1:163,:);zeros(1,7);spectra(164:length(spectra),:)];
% spectra = [spectra(1:164,:);zeros(1,7);spectra(165:length(spectra),:)];
% spectra = [spectra(1:207,:);zeros(1,7);spectra(208:length(spectra),:)];
% spectra = [spectra(1:224,:);zeros(1,7);spectra(225:length(spectra),:)];
% spectra = [spectra(1:225,:);zeros(1,7);spectra(226:length(spectra),:)];
% size(spectra)
% 
% 
% xDspace = [xDspace(1:3); 0.995; xDspace(4:length(xDspace))];
% xDspace = [xDspace(1:23); 1.130; xDspace(24:length(xDspace))];
% xDspace = [xDspace(1:24); 1.440; xDspace(25:length(xDspace))];
% xDspace = [xDspace(1:40);1.540;xDspace(41:length(xDspace))];
% xDspace = [xDspace(1:74);1.640;xDspace(75:length(xDspace))];
% xDspace = [xDspace(1:163);1.7893;xDspace(164:length(xDspace))];
% xDspace = [xDspace(1:164);1.814;xDspace(165:length(xDspace))];
% xDspace = [xDspace(1:207);1.998;xDspace(208:length(xDspace))];
% xDspace = [xDspace(1:224);2.0294;xDspace(225:length(xDspace))];
% xDspace = [xDspace(1:225);2.1280;xDspace(226:length(xDspace))];
% size(xDspace)
% 
% 
% h1=figure(1); set(h1,'Color',[1,1,1]); clf
% h2=waterfall(xDspace,1:7,spectra')
%     set(h2,'edgecolor','k');
%     axis([ 0.90    2.25    0.5 7.5      0    2000 ])
%     set(gca,'Box','on','ZTick',[])
%     strXTickLabels = {'$1.0$','$1.2$','$1.4$','$1.6$','$1.8$','$2.0$','$2.2$'}
% %   strYTickLabel = {'$Cu+Al$','$LiCoO_2$','$Li_{0.75}CoO_2$','$Li_{0.5}CoO2$','$LiC_6$','$LiC_{12}$','$C_6$'}
%     strYTickLabel = {'$\overrightarrow{Cu+Al }$','$\overrightarrow{2}$','$\overrightarrow{3}$','$\overrightarrow{4}$',...
%         '$\overrightarrow{5}$','$\overrightarrow{6}$','$\overrightarrow{7}$'}
%     [hx,hy] = format_ticks(gca,strXTickLabels,strYTickLabel,[],[],[],[],0.06,'FontSize',14,'FontWeight','Bold');
%     h3 = xlabel('d-spacing/\AA','interpreter','latex','FontSize',18,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',14,'Position',position+[0,1.5,0]);
%     h3 = ylabel('eigenvectors','FontSize',18,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',-26,'Position',position+[0.2,0.8,0])
%     h3 = title('fresh battery','FontSize',24,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',0,'Position',position+[0.0,0,-5],'EdgeColor','w')
% %    print -dpng 'Fresh_waterfall_MCR-spectrum.png' -f1
%    print -dpdf 'Fresh_waterfall_MCR-spectrum.pdf' -f1    
% %      print -dtiff 'Fresh_waterfall_MCR-spectrum.tiff' -f1     



%%%%%%%%%%%%%%%%% worn battery analysis %%%%%%%%%%%%%%%%%%%%
clear;
pwd

info = h5info([pwd,'/exptwornallData_v2p092.h5'])  % need xSOCworn and xDspace
info.Datasets.Name
xDspace = h5read([pwd,'/exptwornallData_v2p092.h5'],'/xDspace');  % need xDspace
xSOCworn = h5read([pwd,'/exptwornallData_v2p092.h5'],'/xSOCworn');   % need xSOCworn

index = 2; % worn
filenameMAT_Concentration = dir('copt*.mat');  
filenameMAT_Spectra = dir('sopt*.mat');  

filenameMAT_Concentration(index).name
filenameMAT_Spectra(index).name

concentration = getfield(load(filenameMAT_Concentration(index).name),'sopt');
size(concentration)
spectra = getfield(load(filenameMAT_Spectra(index).name),'copt');
size(spectra)

% spectra = [spectra(1:3,:);  zeros(1,7); spectra(4:length(spectra),:)];
% spectra = [spectra(1:23,:); zeros(1,7); spectra(24:length(spectra),:)];
% spectra = [spectra(1:24,:);zeros(1,7);spectra(25:length(spectra),:)];
% spectra = [spectra(1:40,:);zeros(1,7);spectra(41:length(spectra),:)];
% spectra = [spectra(1:74,:);zeros(1,7);spectra(75:length(spectra),:)];
% spectra = [spectra(1:163,:);zeros(1,7);spectra(164:length(spectra),:)];
% spectra = [spectra(1:164,:);zeros(1,7);spectra(165:length(spectra),:)];
% spectra = [spectra(1:207,:);zeros(1,7);spectra(208:length(spectra),:)];
% spectra = [spectra(1:224,:);zeros(1,7);spectra(225:length(spectra),:)];
% spectra = [spectra(1:225,:);zeros(1,7);spectra(226:length(spectra),:)];
% spectra = [spectra(1:4,:);  zeros(1,7); spectra(5:length(spectra),:)];
% spectra = [spectra(1:41,:);  zeros(1,7); spectra(42:length(spectra),:)];
% size(spectra)
% 
% 
% xDspace = [xDspace(1:3); 0.995; xDspace(4:length(xDspace))];
% xDspace = [xDspace(1:23); 1.130; xDspace(24:length(xDspace))];
% xDspace = [xDspace(1:24); 1.440; xDspace(25:length(xDspace))];
% xDspace = [xDspace(1:40);1.540;xDspace(41:length(xDspace))];
% xDspace = [xDspace(1:74);1.640;xDspace(75:length(xDspace))];
% xDspace = [xDspace(1:163);1.7893;xDspace(164:length(xDspace))];
% xDspace = [xDspace(1:164);1.814;xDspace(165:length(xDspace))];
% xDspace = [xDspace(1:207);1.998;xDspace(208:length(xDspace))];
% xDspace = [xDspace(1:224);2.0294;xDspace(225:length(xDspace))];
% xDspace = [xDspace(1:225);2.1280;xDspace(226:length(xDspace))];
% xDspace = [xDspace(1:4); 1.1095; xDspace(5:length(xDspace))];
% xDspace = [xDspace(1:41); 1.461; xDspace(42:length(xDspace))];
% size(xDspace)
% 
% h1=figure(2); set(h1,'Color',[1,1,1]); clf
% h2=waterfall(xDspace,1:7,spectra')
%     set(h2,'edgecolor','k');
%     axis([ 0.90    2.25    0.5 7.5      0    2000 ])
%     set(gca,'Box','on','ZTick',[])
%     strXTickLabels = {'$1.0$','$1.2$','$1.4$','$1.6$','$1.8$','$2.0$','$2.2$'}
% %   strYTickLabel = {'$Cu+Al$','$LiCoO_2$','$Li_{0.75}CoO_2$','$Li_{0.5}CoO2$','$LiC_6$','$LiC_{12}$','$C_6$'}
%     strYTickLabel = {'$\overrightarrow{Cu+Al }$','$\overrightarrow{2}$','$\overrightarrow{3}$','$\overrightarrow{4}$',...
%         '$\overrightarrow{5}$','$\overrightarrow{6}$','$\overrightarrow{7}$'}
%     [hx,hy] = format_ticks(gca,strXTickLabels,strYTickLabel,[],[],[],[],0.06,'FontSize',14,'FontWeight','Bold');
%     h3 = xlabel('d-spacing/\AA','interpreter','latex','FontSize',18,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',14,'Position',position+[0,1.5,0]);
%     h3 = ylabel('eigenvectors','FontSize',18,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',-26,'Position',position+[0.2,0.8,0])
%     h3 = title('worn battery','FontSize',24,'FontName','Times');
%     position = get(h3, 'Position');
% 	set(h3,'Rotation',0,'Position',position+[0.0,0,-5],'EdgeColor','w')
% %    print -dpng 'Worn_waterfall_MCR-spectrum.png' -f2
%    print -dpdf 'Worn_waterfall_MCR-spectrum.pdf' -f2    
% %      print -dtiff 'Worn_waterfall_MCR-spectrum.tiff' -f2 


concentration = 100 * concentration/max(sum(concentration))

h1=figure(4); set(h1,'Color',[1,1,1]); hold off; clf
h2=plot(xSOCworn,(concentration([2,3,4,7],:))'); hold on;
	set(gca, 'XDir','rev');
    axis([30  100.0000   -0.00002   50 ])
	set(h2(1),'LineWidth',0.5,'Color','c');
    set(h2(2),'LineWidth',0.5,'Color','m');
    set(h2(3),'LineWidth',0.5,'Color','y');
    set(h2(4),'LineWidth',0.5,'Color','g');
h3=plot(xSOCworn,(concentration(1,:)),'bo', 'MarkerSize',10); 
fitobject = fit(xSOCworn,(concentration(1,:))','poly1');
h4 = plot(fitobject,'b');  set(h4,'LineWidth',1);

h3=plot(xSOCworn,(concentration(5,:)),'ks', 'MarkerSize',10); 
fitobject = fit(xSOCworn,(concentration(5,:))','poly1');
h4 = plot(fitobject,'k');  set(h4,'LineWidth',1);

h3=plot(xSOCworn,(concentration(6,:)),'rd', 'MarkerSize',10); 
fitobject = fit(xSOCworn,(concentration(6,:))','poly1');
h4 = plot(fitobject,'r');  set(h4,'LineWidth',1);
legend('off');

set(gca,'FontSize',14,'FontName','Times');
h3 = xlabel('state-of-charge/\%','interpreter','latex','FontSize',18,'FontName','Times');
h3 = ylabel('score/\%','interpreter','latex','FontSize',18,'FontName','Times');
h3 = title('worn battery','FontSize',24,'FontName','Times');
print -dpdf 'Worn_lineplot_MCR-concentration.pdf' -f4

