---
title:  Terrible Horrible No Good Very Bad Python
date:   2025-03-28
extra: {audience: programmers}
description: new and exciting ways to write buggy code
---

time for everyone's favorite game!!

what does this code do?

```python
def foo():
  try:
    return os._exit()
  finally:
    return False

import os
foo()
```

<style type="text/css">
    ol { list-style-type: upper-alpha; }
</style>

does it:
1. return None
2. return False
3. throw an exception
4. exit the process without printing anything
5. something even more devious

sit with it. have a good think. explain your answers.

ready?

<details><summary>ok fine what does it do</summary>

returns `False`. want to know why?

<details><summary>yes just tell me already >:(</summary>

normally, `os._exit` exits the process without running "cleanup handlers" (`finally` blocks). however, it takes one argument. this snippet forgets to pass in the exit code, so instead of exiting, it throws `TypeError`. then the `finally` block silently swallows the exception because of the `return`.

yes someone did write this code by accident and yes they were very confused. i thought it was a bug in cpython until i figured it out.

</details>
</details>

you're welcome!!
