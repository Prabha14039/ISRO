#!/usr/bin/env nextflow

process convert_to_cub {
    tag "$sample"

    input:
    path img_file

    output:
    path "${sample}.cub"

    script:
    sample = img_file.getBaseName().replaceFirst(/\.IMG$/, '')
    """
    lronac2isis from=${img_file} to=${sample}.cub
    """
}

process run_spiceinit {
    tag "$sample"

    input:
    path cub_file

    output:
    path "${sample}.cub"

    script:
    sample = cub_file.getBaseName().replaceFirst(/\.cub$/, '')
    """
    spiceinit from=${sample}.cub web=yes
    """
}

process calibrate {
    tag "$sample"

    input:
    path spiced_file

    output:
    path "${sample}.cal.cub"

    script:
    sample = spiced_file.getBaseName().replaceFirst(/\.cub$/, '')
    """
    lronaccal from=${spiced_file} to=${sample}.cal.cub
    """
}

process echo {
    tag "$sample"

    input:
    path cal_file

    output:
    path "${params.cub_dir}/${sample}.cal.echo.cub"

    script:
    sample = cal_file.getBaseName().replaceFirst(/\.cal\.cub$/, '')
    """
    mkdir -p ${params.cub_dir}
    lronacecho from=${cal_file} to=${params.cub_dir}/${sample}.cal.echo.cub
    """
}

workflow {
    Channel
        .fromPath("${params.img_dir}/*.IMG")
        .set { img_files }

    convert_to_cub(img_files)
        | run_spiceinit
        | calibrate
        | echo
}

