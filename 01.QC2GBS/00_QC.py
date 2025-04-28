import csv
from tqdm import tqdm

aa = "/data1/hyejin/Practice/GBS/data/mvAge.summary.EUR.txt"
with open(aa, 'r') as f1, open("/data1/hyejin/Practice/GBS/data/Aging.txt", 'wt', newline='') as f2:
     reader = csv.reader(f1, delimiter=' ')
     writer = csv.writer(f2, delimiter='\t')
     header = reader.__next__()
     writer.writerow(['SNP', 'A1', 'A2', 'EFFECT', 'SE', 'P', 'MAF'])

     snp = header.index("SNP")
     a1 = header.index("effect_allele")
     a2 = header.index("other_allele")
     effect = header.index("beta")
     se = header.index("se")
     p = header.index('Pvalue')
     maf = header.index('MAF')

     for row in tqdm(reader):
         writer.writerow([row[snp], row[a1], row[a2], row[effect], row[se], row[p], row[maf]])


bb = "/data1/hyejin/Practice/GBS/data/GCST90027158_buildGRCh38.N.tsv"
with open(bb, 'r') as f1, open("/data1/hyejin/Practice/GBS/data/AD.N.txt", 'wt', newline='') as f2:
     reader = csv.reader(f1, delimiter='\t')
     writer = csv.writer(f2, delimiter='\t')
     header = reader.__next__()
     writer.writerow(['SNP', 'A1', 'A2', 'EFFECT', 'SE', 'P', 'MAF', 'N'])

     snp = header.index("variant_id")
     a1 = header.index("effect_allele")
     a2 = header.index("other_allele")
     effect = header.index("beta")
     se = header.index("standard_error")
     p = header.index('p_value')
     maf = header.index('effect_allele_frequency')
     n = header.index('N')

     for row in tqdm(reader):
         writer.writerow([row[snp], row[a1], row[a2], row[effect], row[se], row[p], row[maf], row[n]])


