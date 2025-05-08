% Following code was written for purpose of exercise 6 of laboratory
% classes of Conversion and Analysis of Nonelectrical Signals course.

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% READ DATA %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');


fr_data = readtable('ex6_protocol.xlsx', 'Sheet', 'to_matlab', 'Range', 'A:G');
bfr_data = readtable('ex6_protocol.xlsx', 'Sheet', 'to_matlab', 'Range', 'H:N');

%% grouping by samling time

fr_data = convertvars(fr_data,'samplingTime_s_', 'categorical');
fr_group_tables = create_grouping_tables(fr_data, fr_data.samplingTime_s_);
fr_data_ts1 = fr_group_tables{1}(1:end-8, :);
fr_data_ts3 = fr_group_tables{2};

bfr_data = convertvars(bfr_data,'samplingTime_s_', 'categorical');
bfr_group_tables = create_grouping_tables(bfr_data, bfr_data.samplingTime_s_);
bfr_data_ts1 = bfr_group_tables{1}(376:end-15, :);
bfr_data_ts3 = bfr_group_tables{2}(14:end, :);



function [group_tables] = create_grouping_tables(data, categorical_column)
    [G] = findgroups(categorical_column);
    uniqueGroups = categories(categorical_column);
    
    group_tables = cell(length(uniqueGroups), 1);
    for k = 1:length(uniqueGroups)
        group_tables{k} = data(G == k, :);
    end
end

all_tables = {fr_data_ts1, fr_data_ts3, bfr_data_ts1, bfr_data_ts3};

%%%%%%%%%%%%%%%%%%%
%%%%%% PLOTS %%%%%%
%%%%%%%%%%%%%%%%%%%

%% 1) V(t)

close all
v_t_plot_titles = create_V_plots(all_tables);

function plot_titles = create_V_plots(all_tables)
    plot_titles = cell(1,length(all_tables));
    for k = 1:length(all_tables)
        cutoff = round(0.05*height(all_tables{k}));
        t = all_tables{k}.time./3600;
        V = all_tables{k}.V_calc_dm3_.*1000;
        f = fitlm(t(cutoff:end-cutoff, :),V(cutoff:end-cutoff, :));
        plot_title = 'V(t) ' + string(all_tables{k}.name(1)) + ', sampling time: ' + string(all_tables{k}.samplingTime_s_(1));
        plot_titles{k} = plot_title;
        fprintf('Fitted function for %s: \n', plot_title);
        disp(f);
        fprintf('\n\n')
        figure;
        plot(f);
        title(plot_title, 'Interpreter', 'latex');
        xlabel('time [h]', 'Interpreter', 'latex');
        ylabel('Volume [ml]', 'Interpreter', 'latex');
        legend('Data','Fit','95\% conf. bounds','Location', 'northwest', 'Interpreter', 'latex')
        grid on;
    end
end

%% 2) q,V,inst(t)

q_t_plot_titles = create_q_plots(all_tables);

function plot_titles = create_q_plots(all_tables)
    plot_titles = cell(1,length(all_tables));
    for k = 1:length(all_tables)
        t = all_tables{k}.time./3600;
        q = all_tables{k}.q_v_inst_ml_h_;
        plot_title = '$q_{V,inst}(t)$ ' + string(all_tables{k}.name(1)) + ', sampling time: ' + string(all_tables{k}.samplingTime_s_(1));
        plot_titles{k} = plot_title;
        figure;
        scatter(t, q, 60, '.');
        hold on;
        for i = 1:length(all_tables{k}.time)
            plot([t(i), t(i)], [0, q(i)], 'k');  % vertical line
        end
        title(plot_title);
        xlabel('time [h]');
        ylabel('flow rate [ml/h]');
        grid on;
        hold off;
    end
end

%% 3) save opened figures

figure_titles = [v_t_plot_titles, q_t_plot_titles];
save_all_figures_as_eps(figure_titles);




