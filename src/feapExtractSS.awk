# This program extract from FEAP output file data block
# containing element stresses and strains.
NF == 0 {next}
$0 ~ / *Element Stresses and Strains/  {
  FEASS = 1;
}
FEASS == 1 && $0 ~/ *Command/ { exit }
FEASS == 1 {print $0}
