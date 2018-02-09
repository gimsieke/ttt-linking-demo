# ttt-linking-demo
A demo application for the tokenized-to-tree XProc/XSLT library

## Invocation

This is for Bash (non-MacOS X):

```
calabash/calabash.sh -o out.xml -i source=sample-input/ttt-linking-sample.xml a9s/common/xpl/link-dbk.xpl debug=yes debug-dir-uri=file:/$(cygpath -ma debug)
```

Replace `file:$(readlink -f debug)` with `file:/$(cygpath -ma debug)` for Cygwin.

Replace `readlink -f` with whatever works on MacOS X. You can also just submit a complete file URI. If you give a relative path, it will probably resolve to `xproc-util/store-debug/xpl/`.

Of course you can skip debugging altogether, but it will be interesting to look at the different stages that the content will go through.

Replace `calabash/calabash.sh` with `calabash/calabash.bat` on Windows.

