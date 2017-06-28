#!/bin/bash

year=2011
s=10004953_20111116

SUBJECTS_DIR=/ifs/scratch/pimri/posnerlab/1anal/IDP/fs

IMPATH=/ifs/scratch/pimri/posnerlab/1anal/IDP/${year}/${s}
EXPERTOPT=$SUBJECTS_DIR/expert.opt
FLAIR=`ls $IMPATH/flair*nii`
T1=`ls $IMPATH/t1*nii`
SUBJECT=${s}_05mm_flair
CMD=/ifs/scratch/pimri/posnerlab/1anal/IDP/code/idp/job/cmd.${s}
recon=/ifs/scratch/pimri/posnerlab/1anal/IDP/code/idp/job/recon.${s}

cat<<EOC >$recon
#!/bin/bash
FREESURFER_HOME=/ifs/home/msph/epi/jep2111/app/freesurfer/
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUBJECTS_DIR=/ifs/scratch/pimri/posnerlab/1anal/IDP/fs
echo NOW PERFORMING RECON-ALL
recon-all -all -s ${SUBJECT}.test_mpi128 -hires -i $T1 -expert $EXPERTOPT -FLAIR $FLAIR -FLAIRpial -hippocampal-subfields-T1 -openmp 128 
#recon-all -all -s ${SUBJECT}.test2 -hires -i $T1 -expert $EXPERTOPT -FLAIR $FLAIR -FLAIRpial -hippocampal-subfields-T1T2 $FLAIR -openmp 16
EOC

chmod +x $recon


cat<<-EOM >$CMD
#!/bin/bash
#$ -V
#$ -cwd -S /bin/bash -N reconhigh
#$ -l mem=0.1G,time=168::
#$ -pe orte 128
#$ -l infiniband=TRUE
source /ifs/home/msph/epi/jep2111/.bashrc
. /nfs/apps/openmpi/current/setenv.sh
mpirun $recon
EOM

qsub $CMD
