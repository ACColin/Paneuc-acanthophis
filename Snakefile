configfile: "config.yml"

import acanthophis
acanthophis.populate_metadata(config)


include: acanthophis.rules.base
include: acanthophis.rules.reads
include: acanthophis.rules.align
include: "rules/varcall.rules"
include: acanthophis.rules.multiqc
include: acanthophis.rules.kraken
include: acanthophis.rules.variantannotation

localrules: mpileup, bcfnorm, bcffilter, variantidx, bcfmerge, bamidx

rule all:
    input:
        rules.reads.input,
        rules.align_samples.input,
        rules.varcall.input,
        rules.multiqc.input,
        rules.all_kraken.input,
	rules.varcall.input,

rule prevarcall:
    input:
        rules.reads.input,
        rules.align_samples.input,
        rules.multiqc.input,
        rules.all_kraken.input,
        [expand("data/variants/raw_split/{caller}~{aligner}~{ref}~{sampleset}.bamlist",
               caller=config["varcall"]["samplesets"][sampleset]["callers"],
               aligner=config["varcall"]["samplesets"][sampleset]["aligners"],
               ref=config["varcall"]["samplesets"][sampleset]["refs"],
               sampleset=sampleset
               ) for sampleset in config["varcall"]["samplesets"]],



rule samples_bamstats:
    input:           
    	[expand("data/alignments/bamstats/sample/{aligner}~{ref}~{sample}.samtools.stats", 
               ref=config["align"]["refs"],
               aligner=config["align"]["aligners"],
               sample=config["SAMPLESETS"][sset])
	 for sset in config["align"]["samplesets"]]

