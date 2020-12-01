![alt text](https://github.com/compsecdirect/autodyne/blob/main/Autodyne-CompSecDirect.png "Autodyne logo")  

# Autodyne: Automated firmadyne by CompSec Direct

## Purpose

Improve Firmadyne (https://github.com/firmadyne/firmadyne) and make it simpler to extract, emualte firmware for analysis.  

## Usage

1. Get firmware samples to analyze. ```mkdir samples samples-output``` Add firmware to ```samples``` folder
2. Edit the ```docker-compose.yml``` to include the desired "Manufacturer name" (can be anything) and path to samples.  
a. ```command``` section has  "foo", "1.bin" ; this is the "Manufacturers Name" and file name.  
b. ```volumes``` section has path to firmware samples and mapping to local images.  
3. Copy the relevant sections multiple times (given x samples).
a.copy section from ```emaultor-1``` until next entry.   
4. ```make build and make start```  
5. ```docker exec CONTAINERID bash```  
6. ```tmux ls```  
7. ```tmux a -t "Image ID```  

