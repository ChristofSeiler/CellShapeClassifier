function [type pos day hour] = parseFilenameForLabels(input_filename)

% example: Exp18Myo_A1_1_2009y11m13d_08h00m.jpg

s = input_filename;

[token, s] = strtok(s, '_');
if strcmp(token, 'Exp18Myo') type = 1;
elseif strcmp(token, 'Exp18Osteo') type = 2;
end

[token, s] = strtok(s, '_');
pos = str2num(token(2))*10

[token, s] = strtok(s, '_');
pos = pos + str2num(token);

[token, s] = strtok(s, '_');
day = str2num(token(9:10));

[token, s] = strtok(s, '_');
hour = str2num(token(1:2));
