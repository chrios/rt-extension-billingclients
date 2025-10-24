package RT::Action::SetClientFromEmailDomain;

use strict;
use warnings;
use base 'RT::Action';
use RT::Config;

sub Describe {
    return "Will set the Client custom field from the domain of the requestor";
}

sub Prepare {
    # Always run
    return 1;
}
sub Commit {
    my $ticket  = $self->TicketObj;
    my $cf_name = 'Client';

    return 1 if defined $ticket->FirstCustomFieldValue($cf_name)
             && $ticket->FirstCustomFieldValue($cf_name) ne '';

    my %domain_to_client = %RT::ClientDomainMap;

    sub _email_domain {
        my ($addr) = @_;
        return unless defined $addr && $addr =~ /@/;
        $addr =~ s/.*<([^>]+)>.*/$1/;
        $addr =~ s/^\s+|\s+$//g;
        my ($local, $domain) = split /\@/, $addr, 2;
        return lc($domain // '');
    }

    my @requestor_emails;
    if ($ticket->RequestorsObj->can('MemberEmailAddresses')) {
        @requestor_emails = $ticket->RequestorsObj->MemberEmailAddresses;
    } else {
        my $addrstr = $ticket->RequestorAddresses || '';
        @requestor_emails = grep { $_ ne '' } split /[,\s]+/, $addrstr;
    }

    my $matched_client;
    EMAIL:
    for my $email (@requestor_emails) {
        my $domain = _email_domain($email) || next;

        if (exists $domain_to_client{$domain}) {
            $matched_client = $domain_to_client{$domain};
            last EMAIL;
        }

        my @labels = split /\./, $domain;
        while (@labels > 2) {
            shift @labels;
            my $parent = join('.', @labels);
            if (exists $domain_to_client{$parent}) {
                $matched_client = $domain_to_client{$parent};
                last EMAIL;
            }
        }
    }

    if ($matched_client) {
        my ($ok, $msg) = $ticket->AddCustomFieldValue(
            Field             => $cf_name,
            Value             => $matched_client,
            RecordTransaction => 0,
        );
        $RT::Logger->info("Auto-set CF '$cf_name' to '$matched_client' for ticket ".$ticket->Id) if $ok;
        $RT::Logger->warning("Failed to set CF '$cf_name' for ticket ".$ticket->Id.": $msg") unless $ok;
    }

    return 1;
}

1;