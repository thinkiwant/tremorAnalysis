
n=length(mx);
x=mx;
y=my;
xx=sum(x);
yy=sum(y);
x0=xx/n;%x坐标均值
y0=yy/n;%y坐标均值
xx1=0.0;
yy1=0.0;
xy1=0.0;
for i=1:n
xx1=xx1+(x(i)-x0)^2;
yy1=yy1+(y(i)-y0)^2;
end
Cx2=xx1/n;%x坐标方差
Cy2=yy1/n;%y坐标方差
Cxy0=cov(x,y);
Cxy=Cxy0(1,2);%x、y协方差
%E：长半轴、F：短半轴、ct：长半轴E方位角
E=sqrt(Cx2+Cy2+((Cx2-Cy2)^2+4*Cxy*Cxy))/2;
F=sqrt(Cx2+Cy2-((Cx2-Cy2)^2+4*Cxy*Cxy))/2;
ct=(atan((2*Cxy))/(Cx2-Cy2))/2;
%画误差椭圆
%figure;
plot(x,y,'b*');
%hold on
aerf=0:0.01:2*pi;
plot(x0+E*cos(ct)*cos(aerf)-F*sin(ct)*sin(aerf),y0+E*sin(ct)*cos(aerf)+F*cos(ct)*sin(aerf));
k = sqrt(4.605)*2;
E2=k*E;
F2=k*F;
plot(x0+E2*cos(ct)*cos(aerf)-F*2*sin(ct)*sin(aerf),y0+E2*sin(ct)*cos(aerf)+F2*cos(ct)*sin(aerf));
%E3=3*E;
%F3=3*F;
%plot(x0+E3*cos(ct)*cos(aerf)-F*3*sin(ct)*sin(aerf),y0+E3*sin(ct)*cos(aerf)+F3*cos(ct)*sin(aerf));
%hold off

%%
cop_AREA_CE95([mx',my'])
%%

%clear all;
%close all;

% Create some random data
% s = [2 2];
% x = randn(334,1);
% y1 = normrnd(s(1).*x,1);
% y2 = normrnd(s(2).*x,1);
% data = [y1 y2];
% 
data = [mx', my']

% Calculate the eigenvectors and eigenvalues
covariance = cov(data);
[eigenvec, eigenval ] = eig(covariance);

% Get the index of the largest eigenvector
[largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);

% Get the largest eigenvalue
largest_eigenval = max(max(eigenval));

% Get the smallest eigenvector and eigenvalue
if(largest_eigenvec_ind_c == 1)
    smallest_eigenval = max(eigenval(:,2))
    smallest_eigenvec = eigenvec(:,2);
else
    smallest_eigenval = max(eigenval(:,1))
    smallest_eigenvec = eigenvec(1,:);
end

% Calculate the angle between the x-axis and the largest eigenvector
angle = atan2(largest_eigenvec(2), largest_eigenvec(1));

% This angle is between -pi and pi.
% Let's shift it such that the angle is between 0 and 2pi
if(angle < 0)
    angle = angle + 2*pi;
end

% Get the coordinates of the data mean
avg = mean(data);

% Get the 95% confidence interval error ellipse
chisquare_val = 2.4477;
theta_grid = linspace(0,2*pi);
phi = angle;
X0=avg(1);
Y0=avg(2);
a=chisquare_val*sqrt(largest_eigenval);
b=chisquare_val*sqrt(smallest_eigenval);

% the ellipse in x and y coordinates 
ellipse_x_r  = a*cos( theta_grid );
ellipse_y_r  = b*sin( theta_grid );

%Define a rotation matrix
R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];

%let's rotate the ellipse to some angle phi
r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;

% Draw the error ellipse
plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-r')
hold on;

% Plot the original data
plot(data(:,1), data(:,2), '.');
mindata = min(min(data));
maxdata = max(max(data));
xlim([mindata-3, maxdata+3]);
ylim([mindata-3, maxdata+3]);
hold on;

% Plot the eigenvectors
%quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
%quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
%hold on;

% Set the axis labels
%hXLabel = xlabel('x');
%hYLabel = ylabel('y');
