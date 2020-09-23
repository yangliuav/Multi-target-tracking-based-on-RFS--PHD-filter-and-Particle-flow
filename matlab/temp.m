x = [1:100:100000];
for i =1:1000
    y(i) = besselk(0,x(i)/250000)/pi/500;
end
figure(1)
plot(x,y)