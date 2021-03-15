# efmdraw
Matlab code to draw automatically every efms (elementary flux modes) of a network.

## Installation
This code has to be able to run [Metatool](http://pinguin.biologie.uni-jena.de/bioinformatik/networks/). Store Metatool in the same folder as **efmdraw**, add it to the Matlab path for [the session](http://fr.mathworks.com/help/matlab/ref/addpath.html) or [permanently](https://fr.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html).

## Usage
```MATLAB
efmdraw(model,drawing_design,folder);
```

### ```model```
This parameter represents the network. 
It could be a string containing the path to the file describing the network. The format of this file is the Metatool format, described [here](http://pinguin.biologie.uni-jena.de/bioinformatik/networks/metatool/metatool5.0/ecoli_networks.html).

It could also be a Matlab structure such as
* ```model.irrev``` is a boolean row-vector containing one element for each efm of the network. ```model.irrev(i)``` is equal to 1 if the ith efm is irreversible and 0 if this efm is reversible. It corresponds to ```ex.irrev_ems``` when ```ex``` is the result given by Metatool.
* ```model.ems``` is the matrix of the elementary flux modes: ```model.ems(:,i)``` is the ith efm. It corresponds to the product ```ex.sub' * ex.rd_ems``` when ```ex``` is the result given by Metatool.
* ```model.names``` is a cell array containing the name of each reaction. It correspond to ```ex.react_name``` when ```ex``` is the result given by Metatool.
* ```model.numbers``` is a vector containing the numbers of each efm. Usually it is the vector ```1:length(model.irrev)``` but it could be any vector of number having the same length as ```model.irrev```. Be careful to avoid repetition: ```model.numbers``` is used to label the .xml files (see bellow).

When ```model``` is a structure and not a path, Metatool is not used. So one can use this when the efms are obtained with another method or when some filters are applied to the efm list (see thermoEFM bellow).

### ```drawing_design```
This parameter is a string containing the path to a .xml file created with [CellDesigner](http://www.celldesigner.org/). It is the graphic representation of the network. Every efm will be drawn according to this file. **Warning** Each reaction has to have a name (corresponding to ```model.names``` or the one in the Metatool file).

### ```folder```
This parameter is a string containing the path to the folder where all the file will be stored. The program will create this folder if it doesn't exist. According to the names (see bellow), the program might overwriting some files.

### Results
If ```model``` is "path/to/a/file/named/example_model.dat", ```name``` will be example_model. Else, ```name``` is the name of the .xml file: example_draw in the case where ```drawing_design``` is "path/to/a/file/named/example_draw.xml".

This program will create into the folder ```folder``` the files name_i.xml with ```i``` being the numbers in ```model.numbers``` or 1 to the number of efms of the network.

**efmdraw** can handle relatif and absolute path for files. It can also handle pathes with ```\``` as well as ```/```.

## Projects using efmdraw
* [thermoEFM](https://figshare.com/articles/code/thermoEFM_zip/4620910) (also available [here](https://www.lri.fr/~speres/EFM/thermoEFM.html)). In this project, all the elementary flux modes of the network are first computed. Then they are sorted out between *thermodynamically feasible* and *thermodynamically unfeasible* according to the equilibrium constants. **efmdraw** is then used to draw the feasible ones. Article linked to this project: [Peres et al, 2017](https://doi.org/10.1371/journal.pone.0171440).
