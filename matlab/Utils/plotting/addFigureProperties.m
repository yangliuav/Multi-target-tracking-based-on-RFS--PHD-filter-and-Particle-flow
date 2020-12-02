function addFigureProperties(ps)
% add figure properties for the error time plot and ESS time plot.
%
% input:
% ps: a structure containg the simulation setup and filter parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ps.setup.fontSize = 0.8*ps.setup.fontSize;

alg_names = ps.setup.algs_executed;

for i = 1:2
    figure(i)
    switch i
        case 1
            xlabel('time step','FontSize',ps.setup.fontSize);
            switch ps.setup.example_name
                case {'Acoustic'}
                    ylabel('average OMAT error (m)','FontSize',ps.setup.fontSize);
                otherwise
                    ylabel('average MSE','FontSize',ps.setup.fontSize);
            end
            %%
            magnify();
            set(gca,'FontSize',ps.setup.fontSize);
            h_leg = legend(alg_names,'FontSize',ps.setup.fontSize,'Location','northwest');
            legend(gca,'boxoff');
            set(h_leg,'color','none');

            set(h_leg,'FontSize',ps.setup.fontSize);
            hold off;
        case 2      
            warning('change the algorithm names to those with defined ESS.');
            xlabel('time step','FontSize',ps.setup.fontSize);
            ylabel('average ESS','FontSize',ps.setup.fontSize);
            magnify();
            set(gca,'FontSize',ps.setup.fontSize);
            h_leg = legend(alg_names,'FontSize',ps.setup.fontSize,'Location','northwest');
            legend(gca,'boxoff');
            set(h_leg,'color','none');
            set(h_leg,'FontSize',ps.setup.fontSize); 
            hold off;
    end

   switch i
        case 1
            set(gcf, 'Position', [0, 0, 600,800]);
            switch ps.setup.example_name
                case {'Acoustic'}
                    axis([1 40 0 6.5]);
                otherwise
                    axis([1 10 0 5]);
            end
        case 2
            switch ps.setup.example_name
                case {'Acoustic'}
                    axis([1 40 0 45]);
                otherwise
                    axis([1 10 0 40]);
            end
            set(gcf, 'Position', [0, 0, 600, 600]);
   end
    set(gcf,'color','w');
    grid on;
end

end