%Function drawing the efms of a model in a folder
function efmdraw(model,draw,folder)
	if isa(model,'char')
		%take the model's name if it's a file
		cut = strsplit(model,'/');
		end_cut = cut{length(cut)};
		cut = strsplit(end_cut,'\');
		name_dot = cut{length(cut)};
		cut = strsplit(name_dot,'.');
		name = cut{1};
		
		%Calculate the efms
		ex = metatool(model);
		irrev = ex.irrev_ems;
		ems = ex.sub' * ex.rd_ems;
		names = ex.react_name;
		numbers = 1:length(irrev);
	
	else
		%take the draw's name if model isn't a file
		cut = strsplit(draw,'/');
		end_cut = cut{length(cut)};
		cut = strsplit(end_cut,'\');
		name_dot = cut{length(cut)};
		cut = strsplit(name_dot,'.');
		name = cut{1};
		
		%take the information in the right variable
		irrev = model.irrev;
		ems = model.ems;
		names = model.names;
		numbers = model.numbers;
		
	end
	
	%Collecte the information
	efms=cell(0,1);
	for i = 1:length(irrev)
		efm = containers.Map;
		for(j=1:length(names))
			if(ems(j,i)~=0)
				efm(names{j}) = ems(j,i)<0; %If negativ, we have to change the direction
			end
		end
		efms{end+1} = efm;
	end
	
	%the new width
	width='5.0';
	
	%Read the xml file
	[fid, msg]= fopen(draw, 'r');
	if fid == -1
		disp(['Error opening file ', draw]);
	 	disp(msg);
	  	return;
	end
	xml=cell(0,1);
	while feof(fid) == 0
		finput= fgets(fid);
		xml{end+1}=finput;
	end
	fclose(fid);
	
	%Create the folder if it's needed
	if(~exist(folder))
		mkdir(folder);
	end
	
	%Write the files
	for(i=1:length(irrev))
		efm = efms{i};
		name_file = strcat(folder,'/',name,'_',int2str(numbers(i)),'.xml');
		disp(numbers(i));
		[fid, msg]= fopen(name_file, 'w');
		if fid == -1
			disp(['Error opening file ', name_file]);
		 	disp(msg);
		  	return;
		end 
		in_reaction = false;
		%Write the current file
		for j = 1:length(xml)
			line = xml{j};
			%We modifie the line if it's needed
			%If we are in a reaction of the efm
			if in_reaction
				%the width part
				if length(line)>=19 && strcmp(line(1:19),'<celldesigner:line ')
					regex='width="(.+?)"';
					line=regexprep(line,regex,['width="',width,'"']);
				elseif irrev(i) && efm(name_reaction)
					%change the sens
					line = changeSens(line);
				end
				if length(line)>=11 && strcmp(line(1:11),'</reaction>')
					in_reaction = false;
				end
			elseif length(line)>=9 && strcmp(line(1:9),'<reaction') %we are in a reaction
				%get the name
				regex = 'name="(.+?)"';
				search = regexp(line,regex,'tokens');
				if(length(search)==0)
					disp('ERROR !!')
					disp(['name is missing for the reaction ',line]);
					return;
				end
				name_reaction = search{1};
				name_reaction = name_reaction{1}; %cell vs char
				%Do we have to modifie this reaction ?
				if ~ isempty(find(strcmp(name_reaction,keys(efm))))
					in_reaction = true;
				end
				if in_reaction && irrev(i) %reversible="false"
					line = strrep(line,'reversible="true"','reversible="false"');
					%reversible="true" may not be in the code
					if isempty(strfind(line,'reversible'))
						line = strrep(line,'>',' reversible="false">');
					end
				end
			end
			%We write the line
			fprintf(fid,line);
		end
	end
	disp('Done');
	
	function line = changeSens(line)
		%change reactant with product and Reactant with Product
		if ~isempty(strfind(line,'Product'))
			line = strrep(line,'Product','Reactant');
		elseif ~isempty(strfind(line,'product'))
			line = strrep(line,'product','reactant');
		elseif ~isempty(strfind(line,'Reactant'))
			line = strrep(line,'Reactant','Product');
		elseif ~isempty(strfind(line,'reactant'))
			line = strrep(line,'reactant','product');
		end
    end
end
