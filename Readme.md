# Billing Client extension 

This extension will add rudimentary client billing to your ticket transactions so you can use RT in a client billing scenario (e.g. MSP).

Add something like the following into your RT_SiteConfig.pm:

```perl
Set(%ClientDomainMap, (
    'unitedntds.com.au' => 'United NTDS',
    'eunoialane.com.au' => 'Eunoia Lane',
));
```

Then run

```bash
perl Makefile.PL
make
make install
```

Then you can create transaction queries like below