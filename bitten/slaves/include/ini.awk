BEGIN {
  FS = "="
}

function trim( str )
{
   sub(/^ +/, "", str)
   sub(/ +$/, "", str)
   return str
}

/^\[/ {
  group = substr( $1, 2, length($1) - 2)
}

/^[a-zA-Z]/ && ! /password/ {
   print group"_"trim($1)"=\""trim($2)"\""
}

