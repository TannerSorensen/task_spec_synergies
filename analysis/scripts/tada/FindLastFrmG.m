function LastFrm = FindLastFrmG(fn)

fp = fopen(fn, 'rt'); % open data file
ln = fscanf(fp, '%s', 1); % read first data
while ~isempty(strmatch('%', ln))
    fgetl(fp);
    ln = fscanf(fp, '%s', 1); % read first data of each line
end
ms_frm = str2num(ln); %fscanf(fp, '%f', 1); %msec frame
last_frm = fscanf(fp, '%f', 1); %last frame No.

if ~last_frm
    END = [];
    name = 1;
    while name % until fscanf can't read
        name = fscanf(fp, '%s', 1); % read first data of each line
        if isempty(strmatch('%', name))
            
            tmp = fscanf(fp, '%f', 1); % skip data
            % added by HN 200910
            if isempty(tmp)
                fscanf(fp, '%s', 1); % skip osc_id if any
                fscanf(fp, '%f', 1); % skip data
            end
            
            fscanf(fp, '%f', 1);
            END = [END fscanf(fp, '%f', 1)];
            fgetl(fp);
        else
            fgetl(fp);
        end
    end
    
    LastFrm = max(END);
else
    LastFrm = last_frm;
end

fclose(fp);