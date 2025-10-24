package RT::Action::SyncBillingClientCF;

use strict;
use warnings;
use base 'RT::Action';

sub Describe {
    return "Sync Ticket CF 'Client' to Transaction CF 'Client' when TimeWorked is changed";
}

sub Prepare {
    # Always run
    return 1;
}

sub Commit {

    my $self = shift;
    RT::Logger->debug("SyncBillingClientCF: Commit method triggered for ticket #" . $self->TicketObj->Id);

    my $txn    = $self->TransactionObj;
    my $ticket = $self->TicketObj;

    unless ($txn && $txn->Type eq 'Set' && $txn->Field eq 'TimeWorked') {
        RT::Logger->debug("SyncBillingClientCF: Not a TimeWorked change transaction");
        return 1;
    }

    my $client_value = $ticket->FirstCustomFieldValue('Client');
    unless (defined $client_value) {
        RT::Logger->debug("SyncBillingClientCF: No Client value on ticket #" . $ticket->Id);
        return 1;
    }

    my $cf = RT::CustomField->new($RT::SystemUser);
    $cf->LoadByName(Name => 'Billing Client', LookupType => RT::Transaction->CustomFieldLookupType);

    unless ($cf->Id) {
        RT::Logger->error("SyncBillingClientCF: Transaction CF 'Billing Client' not found");
        return 1;
    }

    my ($status, $msg) = $txn->AddCustomFieldValue(Field => $cf, Value => $client_value);
    unless ($status) {
        RT::Logger->error("SyncBillingClientCF: Failed to set Transaction CF 'Billing Client': $msg");
    } else {
        RT::Logger->info("SyncBillingClientCF: Set Transaction CF 'Billing Client' to '$client_value'");
    }

    return 1;
}

1;