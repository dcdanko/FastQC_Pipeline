

rule fastqc_report:
    input:
            # these file patterns are automatically generated when
            # the snakemake is preprocessed. The definitions used
            # to generate can be found in pipeline_definition.json.
        reads1 = getOriginResultFiles(config, 'raw_short_read_dna', 'read1'),
            reads2 = getOriginResultFiles(config, 'raw_short_read_dna', 'read2')
    output:
        zip1 = config['fastqc_report']['zip1'],
        html1 = config['fastqc_report']['html1'],            
        zip2 = config['fastqc_report']['zip2'],
        html2 = config['fastqc_report']['html2']            
    version: config['fastqc_report']['exc']['version']
    params:
        fastqc = config['fastqc_report']['exc']['filepath'],
    resources:
            time=int(config['fastqc_report']['time']),
        n_gb_ram=int(config['fastqc_report']['ram'])
    run:
            base1 = input.reads1.split('.')[0]
            base2 = input.reads2.split('.')[0]
        cmd = (
                '{params.fastqc} {input.reads1} {input.reads2} && '
                'mv '+base1+'_fastqc.zip {output.zip1} ; '
                'mv '+base2+'_fastqc.zip {output.zip2} ; '
                'mv '+base1+'_fastqc.html {output.html1} ; '
                'mv '+base2+'_fastqc.html {output.html2} ; '                
            )
            shell(cmd)

