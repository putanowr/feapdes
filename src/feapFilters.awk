function colonNumericParam(line,     tokens) {
  split(line, tokens,":");
  return strtonum(tokens[2]); 
}
