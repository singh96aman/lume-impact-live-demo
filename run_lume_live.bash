#!/bin/bash

#######Setting up Parameters for Script#######
helpFunction()
{
   echo ""
   echo "Example Usage: $0 -e lume-live-dev -p 24899 -x /sdf/group/ard/thakur12/lcls-lattice"
   echo -e "\t-e Please pass the environment.yml file name here"
   echo -e "\t-p Please pass the Epics Server Port"
   echo -e "\t-x Please specify the LCLS_LATTICE Path"
   
   echo -e "\nOther Parameters : \n"
   echo -e "\t-d Debug=True/False"
   echo -e "\t-l Live=True/False"
   echo -e "\t-v USE_VCC=True/False"
   echo -e "\t-m Please pass the model name here"
   echo -e "\t-h Please pass the host name here"
   exit 1 # Exit script after printing help
}

#Default Values
export debug=False
export use_vcc=True
export live=True
export model=sc_inj
export host=sdf

while getopts "e:p:x:d:v:l:m:h:" opt
do
   case "$opt" in
      e ) envfile="$OPTARG" ;;
      p ) epicsport="$OPTARG" ;;
      x ) lcls_lattice="$OPTARG" ;;
      d ) debug="$OPTARG" ;;
      v ) use_vcc="$OPTARG" ;;
      l ) live="$OPTARG" ;;
      m ) model="$OPTARG" ;;
      h ) host="$OPTARG" ;; 
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [ -z "$envfile" ] || [ -z "$epicsport" ] || [ -z "$lcls_lattice" ]
then
   echo "Service cannot be started without Environment File, Epics Port and LCLS_LATTICE Location";
   helpFunction
fi

#######Making Conda Environment#######
echo 'Running Conda Environment Commands'
conda init
source ~/.bashrc
conda env create --file "$envfile".yml || echo 'Skipped : Environment Already Exists or Some other issue...'
conda activate "$envfile"

#######Converting Jupyter Notebook to Python Files and Creating Folders#######
echo 'Converting Jupyter Notebook to Python Files and Creating Folders'
jupyter nbconvert --to script lume-impact-live-demo.ipynb 
# jupyter nbconvert --to script make_dashboard.ipynb
# jupyter nbconvert --to script get_vcc_image.ipynb

mkdir -p archive
mkdir -p output
mkdir -p plot
mkdir -p snapshot
mkdir -p log

#######Checking if Process is able to connect to Epics#######
echo 'Checking if Process is able to connect to Epics'
export EPICS_CA_NAME_SERVERS=localhost:"$epicsport"
caget KLYS:LI22:11:KPHR || echo 'If this returns an ERROR, Try Another Port by\n 
ssh -fN -L 24666:lcls-prod01.slac.stanford.edu:5068 centos7.slac.stanford.edu\n
Pass the new port (example - 24666) and run the file again'
export LCLS_LATTICE="$lcls_lattice"

#######Logging Repository#######
echo 'Running lume-impact-live-demo.py'
ipython lume-impact-live-demo.py -- -d "$debug" -v "$use_vcc" -l "$live" -m "$model" -t "$host"

echo 'All Done!'