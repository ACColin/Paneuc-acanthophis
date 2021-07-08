configfile: "config.yml"

import acanthophis
acanthophis.populate_metadata(config)


include: acanthophis.rules.base
include: acanthophis.rules.reads
include: acanthophis.rules.align
include: acanthophis.rules.varcall
include: acanthophis.rules.multiqc
include: acanthophis.rules.kraken
include: acanthophis.rules.variantannotation

localrules: mpileup, bcfnorm, bcffilter, variantidx, bcfmerge

rule all:
    input:
        rules.reads.input,
        rules.align_samples.input,
        rules.varcall.input,
        rules.multiqc.input,
        rules.all_kraken.input,

rule samples_bamstats:
    input:           
    	[expand("data/alignments/bamstats/sample/{aligner}~{ref}~{sample}.samtools.stats", 
               ref=config["align"]["refs"],
               aligner=config["align"]["aligners"],
               sample=config["SAMPLESETS"][sset])
	 for sset in config["align"]["samplesets"]]

