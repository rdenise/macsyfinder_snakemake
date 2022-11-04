##########################################################################


rule macsyfinder:
    input:
        fasta=os.path.join(FASTA_FOLDER, f"{{replicon}}.{EXT_FILE}"),
    output:
        results=directory(
            os.path.join(
                OUTPUT_FOLDER,
                "REPLICONS",
                "{replicon}",
            ),
        ),
    params:
        macsydata=config["macsydata"],
        db_type=config["db_type"],
	cut_ga="" if config["cut_ga"] else "--cut-ga",
        replicon_topology=config["replicon_topology"],
        models=lambda wildcards: dict_models[wildcards.replicon] if wildcards.replicon in dict_models else config["models"],
    log:
        os.path.join(
            OUTPUT_FOLDER,
            "logs",
            "macsyfinder",
            "{replicon}.log",
        ),
    threads: 1
    conda:
        "../envs/macsyfinder.yaml"
    shell:
        """
        if [[ -s {input.fasta:q} ]] ; then
            macsyfinder --models-dir {params.macsydata:q} --sequence-db {input.fasta:q} -o {output.results:q} --db-type {params.db_type} --replicon-topology {params.replicon_topology} -w {threads} --models {params.models} {params.cut-ga} &> {log:q}
        else
            echo {input.fasta}
            mkdir -p {output.results:q}
        fi
        """


##########################################################################


rule macsymerge:
    input:
        results_macsyfinder=expand(
            os.path.join(
                OUTPUT_FOLDER,
                "REPLICONS",
                "{replicon}",
            ),
            replicon=REPLICON_NAME
        ),
    output:
        merge=directory(
            os.path.join(
                OUTPUT_FOLDER,
                "merge_results",
            )
        ),
    log:
        os.path.join(
            OUTPUT_FOLDER,
            "logs",
            "macsymerge.log",
        ),
    threads: 1
    conda:
        "../envs/macsyfinder.yaml"
    shell:
        """
        ulimit -S -s unlimited

        macsymerge --out-dir {output.merge:q} {input.results_macsyfinder:q} &> {log:q}
        """


##########################################################################


rule macsyprofile:
    input:
        results=os.path.join(
            OUTPUT_FOLDER,
            "REPLICONS",
            "{replicon}",
        ),
    output:
        results=os.path.join(
            OUTPUT_FOLDER,
            "REPLICONS",
            "{replicon}",
            "hmm_coverage.tsv",
        ),
    log:
        os.path.join(
            OUTPUT_FOLDER,
            "logs",
            "macsyprofile",
            "{replicon}.log",
        ),
    threads: 1
    conda:
        "../envs/macsyfinder.yaml"
    shell:
        """
        macsyprofile {input.results:q}
        """


##########################################################################
