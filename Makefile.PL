use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'RT::Extension::BillingClient',
    VERSION_FROM => 'lib/RT/Action/SyncBillingClientCF.pm', # or any other .pm file with $VERSION
    ABSTRACT     => 'Sync Billing Client CF and set Client CF from email domain',
    AUTHOR       => 'Christopher Frew <christopher.frew@mawsontech.com.au>',
    LICENSE      => 'gpl',
    PREREQ_PM    => {
        'RT' => 6.0,
    },
    EXE_FILES    => [],
    PM           => {
        'lib/RT/Action/SyncBillingClientCF.pm'     => '$(INST_LIBDIR)/SyncBillingClientCF.pm',
        'lib/RT/Action/SetClientFromEmailDomain.pm' => '$(INST_LIBDIR)/SetClientFromEmailDomain.pm',
    },
    clean        => { FILES => 'RT-Extension-BillingClient-*' },
);