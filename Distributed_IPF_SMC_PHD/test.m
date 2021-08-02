
figure(10);hold on;
title('target numbers estimation');
plot(t1);
hold on;
plot(t2);
hold on;
plot(t3);
hold on;
plot(t4);
hold on;
plot(t5);
hold on;
ylabel('Target Number');
xlabel('Frame Number');
xlim([1,20])
ylim([0,6])
legend('Sensor-1','Sensor-2','Sensor-3','Sensor-4','Sensor-5');

figure(11);hold on;
title('OSPA in each sensor');
plot(o1);
hold on;
plot(o2);
hold on;
plot(o3);
hold on;
plot(o4);
hold on;
plot(o5);
hold on;
ylabel('OSPA');
xlabel('Frame Number');
xlim([1,20])
ylim([0,40])
legend('Sensor-1','Sensor-2','Sensor-3','Sensor-4','Sensor-5');