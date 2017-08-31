function run_extract_features(input_dir,filter,output_filename)

list=dir([input_dir,filter]);
M = [];
for i=3:length(list)
    list(i).name
    I = imread([input_dir,list(i).name]);
    [TMP BWdfill Overlay Urelaxed] = extractFeatures(I,false);
    if TMP ~= 0
        [type pos day hour] = parseFilenameForLabels(list(i).name);
        
        v = ones(size(TMP,1),1);
        vtype = type*v;
        vpos = pos*v;
        vday = day*v;
        vhour = hour*v;
        
        TMP = [TMP vtype vpos vday vhour];
        M = [M; TMP];
        imwrite(BWdfill,['./BWdfill/',list(i).name,'_BWdfill.png'],'png')
        imwrite(Overlay,['./Overlay/',list(i).name,'_Overlay.png'],'png')
        csvwrite(['./Urelaxed/',list(i).name,'_Urelaxed.dat'],Urelaxed)
        csvwrite(output_filename,M)
	end
end
