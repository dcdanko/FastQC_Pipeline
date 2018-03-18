import os
import tempfile
import shutil

rule multiqc_report:
    input:
        # The expandGroup function is imported from moduleUltra (automatically)
        # It gets every file matching the pattern from the group being processed
        expandGroup( config['fastqc_report']['zip1'], config['fastqc_report']['zip2'])
    output:
        html = config['multiqc_report']['html'],
        fastqc = config['multiqc_report']['fastqc'],
        gstats = config['multiqc_report']['gstats'],
        sources = config['multiqc_report']['sources']
    threads: 1
    params:
        exc=config['multiqc_report']['exc']['filepath'],
        ext = config['multiqc_report']['zip_ext'],
        group_name='{group_name}'
    resources:
        time=1,
        n_gb_ram=10
    run:

        tempdir = tempfile.mkdtemp(dir='.')
        for inp in input:
            dst = os.path.join(tempdir, os.path.basename(inp))
            os.symlink(os.path.abspath(inp), dst)
        cmd = ('{params.exc} '
               '--cl_config "sp: {{fastqc/zip: {{fn: \'*{params.ext}\'}}}}" '
               '-o {params.group_name}_multiqc ')
        cmd += tempdir + ' ; '
        
        bhtml = '{}_multiqc/multiqc_report.html'.format(params.group_name)
        bfastqc = '{}_multiqc/multiqc_data/multiqc_fastqc.txt'.format(params.group_name)
        bgstats = '{}_multiqc/multiqc_data/multiqc_general_stats.txt'.format(params.group_name)
        bsources = '{}_multiqc/multiqc_data/multiqc_sources.txt'.format(params.group_name)

        
        cmd += (
            'mv '+bhtml+' {output.html} ; '
            'mv '+bfastqc+' {output.fastqc} ; '
            'mv '+bgstats+' {output.gstats} ; '
            'mv '+bsources+' {output.sources} ; '                
        )

        shell(cmd)
        shutil.rmtree(tempdir)
