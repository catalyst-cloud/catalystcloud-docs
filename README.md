# Catalyst Cloud Documentation

This is the official documentation for the [Catalyst Cloud](https://catalystcloud.nz/).

## Contributions

If you have anything to fix or details to add, please consult [Contributing to the documentation](http://docs.catalystcloud.nz/contributing.html).

### Live development server

To start a live reloading server, run:

```shell
make live
```
Then navigate in your preferred browser to `localhost:8000`.

Changes from files edited in the `source` directory will now be updated in the browser
after a brief delay. This makes editing the documentation and judging the effects
of your changes much easier.

To validate, build and check the external links use the command:

```shell
make compile
```

### External link checking

If you add example URLs to the documentation that are not resolvable external 
links, for example `http://localhost:8080` then add the link to `source/conf.py` under
the setting `linkcheck_ignore`.

## Licence

Unless otherwise specified, everything in this repository is covered by the following licence:

[![Creative Commons Attribution-ShareAlike 4.0 International](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)

***Catalyst Cloud Documentation*** by the [Catalyst Cloud Team](https://catalystcloud.nz) is licensed under a [Creative Commons Attribution 4.0 International Licence](http://creativecommons.org/licenses/by-sa/4.0/).
