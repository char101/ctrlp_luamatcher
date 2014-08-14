## Overview

Matcher function for [https://github.com/kien/ctrlp.vim](ctrlp) implemented in lua.

Other implementation:

	* [https://github.com/FelikZ/ctrlp-py-matcher/](ctrlp-py-matcher) in python
	* [https://github.com/JazzCore/ctrlp-cmatcher/](ctrlp-cmatcher) in C

## Usage

```
let g:ctrlp_match_func = { 'match': 'ctrlp#luamatcher#Match' }
```
