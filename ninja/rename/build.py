import ninja_syntax
import os
import sys
from os.path import basename, splitext

writer = ninja_syntax.Writer(sys.stdout)
writer.rule("python", "python $in > $out")
writer.build("build.ninja", "python", "build.py", implicit=["src"])

writer.rule("cc", "cc $in -o $out")
for path in os.listdir('src'):
    base, ext = splitext(path)
    if ext == '.c':
        writer.build('src/'+base, "cc", 'src/'+path)

# for path in os.listdir('.'):
#     base, ext = splitext(path)
#     if ext == '.c':
#         writer.build(basename(path), "cc", path)
