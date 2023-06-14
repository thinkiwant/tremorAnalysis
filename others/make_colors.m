function palette = make_colors(col_num)

% Generate colors to be used in the Plotting

if nargin == 1
    if isnumeric(col_num)
        if col_num < 7
            colors = cell(6,1);
            colors{1} = [0 0.4470 0.7410];
            colors{2} = [0.8500 0.3250 0.0980];
            colors{3} = [0.4660 0.6740 0.1880];
            colors{4} = [0.4940 0.1840 0.5560];
            colors{5} = [0.9290 0.6940 0.1250];
            colors{6} = [0.6350 0.0780 0.1840];
            palette = colors;
        else
        % colors from website: wahart.com.hk/rgb.htm
%         colors{1} = '#FFFAF0';
%         colors{2} = '#FFEBCD';
%         colors{3} = '#FFF8DC';
%         colors{4} = '#F5FFFA';
%         colors{5} = '#FFE4E1';
%         colors{6} = '#708090';\
            rgb = 256;
            % color 1-6: from matlab documents
            colors{1} = [0 0.4470 0.7410]; % blue
            colors{2} = [0.8500 0.3250 0.0980]; % orange 
            colors{3} = [0.4660 0.6740 0.1880]; % green
            colors{4} = [0.4940 0.1840 0.5560]; % puple 
            colors{5} = [0.9290 0.6940 0.1250]; % yellow
            colors{6} = [0.6350 0.0780 0.1840]; % dark red
            colors{7} = [200 92 92]/rgb; % shallow red
            colors{8} = [92 200 92]/rgb; % green 
            colors{9} = [245 194 65]/rgb; % yellow
            colors{10} = [92 92 200]/rgb; % puple
            colors{11} = [47 79 79]/rgb; % DarkSlateGrey
            colors{12} = [105 105 105]/rgb; % DimGrey
            colors{13} = [25 25 112]/rgb; % MidnightBlue
            colors{14} = [100 149 237]/rgb; % CornflowerBlue
            colors{15} = [0 191 255]/rgb; % DeepSkyBlue
            colors{16} = [64 224 208]/rgb; % Turquoise
            colors{17} = [85 107 47]/rgb; % DarkOliveGreen
            colors{18} = [0 250 154]/rgb; % MedSpringGreen
            colors{19} = [205 92 92]/rgb; % IndianRed
            colors{20} = [210 105 30]/rgb; % Chocolate
            colors{21} = [218 112 214]/rgb; % Orchid
            colors{22} = [238 201 0]/rgb; % Gold2
            colors{23} = [130 26 26]/rgb; % Firebrick4
            colors{24} = [34 139 34]/rgb; % ForestGreen
        
%         
%         colors{7} = '#000080';
%         colors{8} = '#8470FF';
%         colors{9} = '#00BFFF';
%         colors{10} = '#ADD8E6';
%         colors{11} = '#40E0D0';
%         colors{12} = '#7FFFD4';
%         colors{13} = '#3CB371';
%         colors{14} = '#00FF00'; % green
%         colors{15} = '#9ACD32'; % YellowGreen
%         colors{16} = '#FAFAD2'; % LtGoldenrodYellow
%         colors{17} = '#DAA520'; % goldenrod
%         colors{18} = '#A0522D'; % Sienna
%         colors{19} = '#F4A460'; % SandyBrown
%         colors{20} = '#E9967A'; % DarkSalmon
%         colors{21} = '#FF7F50'; % Coral
%         colors{22} = '#FF69B4'; % HotPink
%         colors{23} = '#B03060'; % Maroon
%         colors{24} = '#DDA0DD'; % Plum
%         colors{25} = '#8A2BE2'; % BlueViolet
%         colors{26} = '#EEE9E9'; % Snow2
%             n = floor(length(colors)/col_num)-1;
%             for k = 1:n
%                 palette{k}= colors{1+k*(col_num-1)};
%             end
            palette = colors;
        end
    end
elseif isstring(col_num)
    if strcmp(col_num,'grey')
        colors{1} = [169 169 169];
        colors{2} = [28 28 28]; % grey11
        colors{3} = [54 54 54]; % grey21
        colors{4} = [79 79 79]; % grey31
        colors{5} = [105 105 105]; % grey41
        colors{6} = [130 130 130]; % grey51
        colors{7} = [156 156 156]; % grey61
        colors{8} = [181 181 181]; % grey71
        colors{9} = [207 207 207]; % grey81
        colors{10} = [232 232 232]; % grey91
        palette = colors;
%     disp('Other functions need to be added')
    else
        disp('Other functions need to be added')
    end
    
end

end
    