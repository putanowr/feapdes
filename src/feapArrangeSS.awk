# This program rearranges output of feapExtractSS.awk
# by merging single Gauss Point's data into one line.
# It also allows selective output of stresses, strinas
# and their eigenvalues depending of the value of:
# printStres, printStrain, and printEig.
# reccors arrangement:
# elem  gpnum gp_coords { stresses} {strains} {eigvalues}
# where gp_coors :=> x, y {z}
# stresses :=> sigma_xx, sigma_yy, sigma_xy
# strains :=> eps_xx, eps_yy, eps_xy
# eigenvalues :=> s1, s2, angle
BEGIN {
 j = 0;
 oldelem=0;
}
NF == 0 {next}
$0 ~ / FEAP \* \*/ {next} 
$0 ~ / *Element Stresses and Strains/  {
  for (i=0; i<5; ++i) getline;
  next
}
{ if (NF == 4) { dim=2;
  } else { dim =  3;}
  if ($1 != oldelem) {
    oldelem=$1;
    j = 0;
  }
  j = j+1;
  printf("%s %d %s %s", $1, j, $3, $4)
  if (dim == 3) printf(" %s", $5);
  getline pv;
  getline;
  if (printStress) {
    if (dim == 2) $3="";
    printf(" %s", $0)
  }
  getline;
  if (printStrain) { 
    if (dim == 2) $3="";
    printf(" %s", $0)
  }
  if (printEig) {
    n = split(pv, v, " ");
    if (printStress) {
      for (i=1; i<=n/2; ++i) { printf(" %s", v[i]) }
    } 
    if (printStrain) {
      for (i=n/2+1; i<=n; ++i) { printf(" %d", v[i]) }
    }
  }
  printf("\n");
}
