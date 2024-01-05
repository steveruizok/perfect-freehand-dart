## perfect_freehand test_fixes

The Dart files and their corresponding `.expect` files are used to
test this package's refactorings used with the `dart fix` command.

To test these fixes locally, run:
```bash
cd test_fixes
dart fix --compare-to-golden
```

See
[lib/fix_data.yaml](https://github.com/adil192/perfect_freehand/blob/main/lib/fix_data.yaml)
for the current data-driven fixes.

For more documentation about Data Driven Fixes, see
https://dart.dev/go/data-driven-fixes.
