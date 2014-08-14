## Overview

Matcher function for [ctrlp](https://github.com/kien/ctrlp.vim) implemented in lua.

Other implementation:

* [ctrlp-py-matcher](https://github.com/FelikZ/ctrlp-py-matcher/) in python
* [ctrlp-cmatcher](https://github.com/JazzCore/ctrlp-cmatcher/) in C

## Usage

```
let g:ctrlp_match_func = { 'match': 'ctrlp#luamatcher#Match' }
```
