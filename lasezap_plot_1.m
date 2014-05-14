set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultTextFontSize', 20)
    
%% load data
dist = 10;
current = 2300;

Step1 = xlsread('laft_30um_4to35_1400_TCF_140408182225.xls',1,'A2:D33');

power_level = Step1(:,1);
F_1 = Step1(:,2);
Q_1 = Step1(:,3);
Rx_1 = Step1(:,4);

%% curve fit
fit_level = 1:32;
fit_degree = 2;
select = [1:10,12:32];
linspace_num = 32;

% for step 1
F_fit_1 = polyval(polyfit(power_level(select),F_1(select),fit_degree),fit_level);
Q_fit_1 = polyval(polyfit(power_level(select),Q_1(select)./1000,fit_degree),fit_level);
Rx_fit_1 = polyval(polyfit(power_level(select),Rx_1(select)./1000,fit_degree),fit_level);
Q_fit_F1 = polyval(polyfit(F_1(select),Q_1(select)./1000,fit_degree),linspace(min(F_1(select)),max(F_1(select)),linspace_num));
%% plot
dist = 10;
current = 2300;
fontsize = 18;
markersize = 10;


f3 = figure(3);

% plot fit curve

subplot 141,plot(fit_level,F_fit_1,'b','LineWidth',4),hold on;
subplot 142,plot(fit_level,Q_fit_1,'b','LineWidth',4),hold on;
subplot 143,plot(fit_level,Rx_fit_1,'b','LineWidth',4),hold on;
subplot 144,plot(linspace(min(F_1(select)),max(F_1(select)),linspace_num),Q_fit_F1,'b','LineWidth',4),hold on;

subplot 141,plot(power_level(select),F_1(select),'xb','LineWidth',3,'MarkerSize',markersize);
subplot 142,plot(power_level(select),Q_1(select)./1000,'xb','LineWidth',3,'MarkerSize',markersize);
subplot 143,plot(power_level(select),Rx_1(select)./1000,'xb','LineWidth',3,'MarkerSize',markersize);
subplot 144,plot(F_1(select),Q_1(select)./1000,'xb','LineWidth',3,'MarkerSize',markersize);

subplot 141,grid on,xlabel('Laser Power Level','FontSize',fontsize);ylabel('Delta Fo (ppm)','FontSize',fontsize);title('Delta Fo vs Laser Power Level','FontSize',fontsize)
subplot 142,grid on,xlabel('Laser Power Level','FontSize',fontsize);ylabel('Delta Q (k)','FontSize',fontsize);title('Delta Q vs Laser Power Level','FontSize',fontsize)
subplot 143,grid on,xlabel('Laser Power Level','FontSize',fontsize);ylabel('Delta Rx (k ohm)','FontSize',fontsize);title('Delta Rx vs Laser Power Level','FontSize',fontsize)
subplot 144,grid on,xlabel('Delta Fo (ppm)','FontSize',fontsize);ylabel('Delta Q (k)','FontSize',fontsize);title('Delta Q vs Delta Fo','FontSize',fontsize);


% plot ends
subplot 141,hold off
subplot 142,hold off
subplot 143,hold off
subplot 144,hold off

%% Plot 2
dist = 10;
current = 2300;
fontsize = 18;
markersize = 10;


f3 = figure(3);

% plot fit curve

subplot 121,plot(fit_level,F_fit_1,'b','LineWidth',4),hold on;
subplot 122,plot(linspace(min(F_1(select)),max(F_1(select)),linspace_num),Q_fit_F1,'b','LineWidth',4),hold on;

subplot 121,plot(power_level(select),F_1(select),'xb','LineWidth',3,'MarkerSize',markersize);
subplot 122,plot(F_1(select),Q_1(select)./1000,'xb','LineWidth',3,'MarkerSize',markersize);

subplot 121,grid on,xlabel('Laser Power Level','FontSize',fontsize);ylabel('Delta Fo (ppm)','FontSize',fontsize);title('Delta Fo vs Laser Power Level','FontSize',fontsize)
subplot 122,grid on,xlabel('Delta Fo (ppm)','FontSize',fontsize);ylabel('Delta Q (k)','FontSize',fontsize);title('Delta Q vs Delta Fo','FontSize',fontsize);


% plot ends
subplot 121,hold off
subplot 122,hold off





