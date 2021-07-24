# Grandis
REF=rawdata/references/Egrandis_phytozome13_v2.0/Egrandis_297_v2.0.softmasked.fa
qsub -v REF=$REF,KEY=mpileup~bwa~Egrandis_phytozome13_v2~HBDecra gadi/pbsvc.sh
qsub -v REF=$REF,KEY=mpileup~bwa~Egrandis_phytozome13_v2~RA-Adnataria gadi/pbsvc.sh

#REF=rawdata/references/scott/E_brandiana/E_brandiana_softmask_chl.fasta
#qsub -v REF=$REF,KEY=mpileup~bwa~Ebrandiana_sf~HBDecra gadi/pbsvc.sh
#qsub -v REF=$REF,KEY=mpileup~bwa~Ebrandiana_sf~RA-Adnataria gadi/pbsvc.sh
#
#REF=rawdata/references/scott/E_sideroxylon/E_sideroxylon_softmask_chl.fasta
#qsub -v REF=$REF,KEY=mpileup~bwa~Esideroxylon_sf~HBDecra gadi/pbsvc.sh
#qsub -v REF=$REF,KEY=mpileup~bwa~Esideroxylon_sf~RA-Adnataria gadi/pbsvc.sh
