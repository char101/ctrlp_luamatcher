## Overview

Matcher function for [ctrlp](https://github.com/kien/ctrlp.vim) implemented in lua.

Other implementation:

* [ctrlp-py-matcher](https://github.com/FelikZ/ctrlp-py-matcher/) in python
* [ctrlp-cmatcher](https://github.com/JazzCore/ctrlp-cmatcher/) in C

## Usage

```
let g:ctrlp_match_func = { 'match': 'ctrlp#luamatcher#Match' }
```

## Implementation

The fuzzy match is implemented as pattern: ```abc``` -> ```a[^a]*b[^b]*c[^c]*```

The results are then sorted by length.
