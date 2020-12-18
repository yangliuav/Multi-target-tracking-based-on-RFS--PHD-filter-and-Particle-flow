function drawresult(tracking_output,setup)
     dt = datestr(now,'yyyymmddHHMM')
     dt = [dt,'.png'];
     path = './result/';
%         print(gcf,'-dpng',path);

     cmap = hsv(4);
     figure(10);clf;hold on;
     set(gcf, 'Position', [100, 100, 1000, 900]);
     fontsize = 24; 
     grid on;
     plot([0:40],ones(1,41)*4,'-','Color','k','LineWidth',3,'MarkerSize',30,'DisplayName','True'); 
     if ismember('SMC_PHD',setup.algs)
        plot([1:40],tracking_output.SMC_PHD.Nspeakerx,'o-','Color',cmap(1,:),'LineWidth',3,'MarkerSize',30,'DisplayName','SMC-PHD'); 
     end
     if ismember('ZPF-SMC_PHD',setup.algs)
        plot([1:40],tracking_output.ZPFSMC.Nspeakerx,'o-','Color',cmap(2,:),'LineWidth',3,'MarkerSize',30,'DisplayName','ZPF-SMC-PHD'); 
     end
     if ismember('NPF-SMC_PHD',setup.algs)
        plot([1:40],tracking_output.NPFSMC.Nspeakerx,'o-','Color',cmap(3,:),'LineWidth',3,'MarkerSize',30,'DisplayName','NPF-SMC-PHD'); 
     end
     if ismember('NPF-SMC_PHD_S',setup.algs)
        plot([1:40],tracking_output.NPFSMCS.Nspeakerx,'o-','Color',cmap(4,:),'LineWidth',3,'MarkerSize',30,'DisplayName','NPF-SMC-PHD_S'); 
     end
     set(gca,'xtick',0:5:40,'ytick',0:1:6,'FontSize',fontsize);
     set(gcf,'color','w');
     xlabel('Frame Number','FontSize',fontsize);
     ylabel('Number of speakers','FontSize',fontsize);
     legend('show')
     print(gcf,'-dpng',[path,'Nspeaker',dt]);
     
     
     figure(11);clf;hold on;
     set(gcf, 'Position', [100, 100, 1000, 900]);
     fontsize = 24; 
     grid on;
     if ismember('SMC_PHD',setup.algs)
        plot([1:40],tracking_output.SMC_PHD.OSPA,'o-','Color',cmap(1,:),'LineWidth',3,'MarkerSize',30,'DisplayName',['SMC-PHD(',num2str(mean(tracking_output.SMC_PHD.OSPA)),')']); 
     end
     if ismember('ZPF-SMC_PHD',setup.algs)
        plot([1:40],tracking_output.ZPFSMC.OSPA,'o-','Color',cmap(2,:),'LineWidth',3,'MarkerSize',30,'DisplayName',['ZPF-SMC-PHD(', num2str(mean(tracking_output.ZPFSMC.OSPA)),')']); 
     end
     if ismember('NPF-SMC_PHD',setup.algs)
        plot([1:40],tracking_output.NPFSMC.OSPA,'o-','Color',cmap(3,:),'LineWidth',3,'MarkerSize',30,'DisplayName',['NPF-SMC-PHD(',num2str(mean(tracking_output.NPFSMC.OSPA)),')']); 
     end
     if ismember('NPF-SMC_PHD_S',setup.algs)
        plot([1:40],tracking_output.NPFSMCS.OSPA,'o-','Color',cmap(4,:),'LineWidth',3,'MarkerSize',30,'DisplayName',['NPF-SMC-PHD_S(',num2str(mean(tracking_output.NPFSMCS.OSPA)),')']); 
     end
     set(gca,'xtick',0:5:40,'ytick',0:1:20,'FontSize',fontsize);
     set(gcf,'color','w');
     xlabel('Frame Number','FontSize',fontsize);
     ylabel('OSPA','FontSize',fontsize);
     legend('show')
     print(gcf,'-dpng',[path,'OSPA',dt]);
end