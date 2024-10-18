from os import listdir as ls
import gzip
cactus_dir = 'raw_data/cactus_aligns/gene_aligns/'
for file in ls(cactus_dir)[15000:]:
    gene = file.split('.')[1]
    with gzip.open(cactus_dir+file, 'rt') as f:
        lines = f.readlines()
    for i in range(len(lines)):      
        if '>vs' in lines[i]:
            lines[i] = '>' + lines[i].replace('\t','_').split('_')[1] + '\n'
        elif '>REFERENCE' in lines[i]:
            lines[i] = '>GRCh38\n'
    with gzip.open('data/alignments/'+gene+'.fasta.gz','wt') as f:
        f.writelines(lines)

print('finished rewrite')
