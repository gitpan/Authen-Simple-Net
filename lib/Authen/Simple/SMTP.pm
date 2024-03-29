package Authen::Simple::SMTP;

use strict;
use warnings;
use base 'Authen::Simple::Adapter';

use Net::SMTP;
use Params::Validate qw[];

our $VERSION = 0.2;

__PACKAGE__->options({
    host => {
        type     => Params::Validate::SCALAR,
        default  => 'localhost',
        optional => 1
    },
    port => {
        type     => Params::Validate::SCALAR,
        default  => 25,
        optional => 1
    },
    timeout => {
        type     => Params::Validate::SCALAR,
        default  => 60,
        optional => 1
    }
});

sub check {
    my ( $self, $username, $password ) = @_;

    my $connection = Net::SMTP->new(
        Host    => $self->host,
        Port    => $self->port,
        Timeout => $self->timeout
    );

    unless ( defined $connection ) {

        my $host   = $self->host;
        my $reason = $@ || $! || 'Unknown reason';

        $self->log->error( qq/Failed to connect to '$host'. Reason: '$reason'/ )
          if $self->log;

        return 0;
    }

    unless ( $connection->auth( $username, $password ) ) {

        chomp( my $message = $connection->message || 'Unknown reason' );

        $self->log->debug( qq/Failed to authenticate user '$username'. Reason: '$message'/ )
          if $self->log;

        return 0;
    }

    $self->log->debug( qq/Successfully authenticated user '$username'./ )
      if $self->log;

    return 1;
}

1;

__END__

=head1 NAME

Authen::Simple::SMTP - Simple SMTP authentication

=head1 SYNOPSIS

    use Authen::Simple::SMTP;
    
    my $smtp = Authen::Simple::FTP->new( 
        host => 'smtp.company.com'
    );
    
    if ( $smtp->authenticate( $username, $password ) ) {
        # successfull authentication
    }
    
    # or as a mod_perl Authen handler
    
    PerlModule Authen::Simple::Apache
    PerlModule Authen::Simple::SMTP

    PerlSetVar AuthenSimpleSMTP_host "smtp.company.com"

    <Location /protected>
      PerlAuthenHandler Authen::Simple::SMTP
      AuthType          Basic
      AuthName          "Protected Area"
      Require           valid-user
    </Location>

=head1 DESCRIPTION

Authenticate against a SMTP service.

=head1 METHODS

=over 4

=item * new

This method takes a hash of parameters. The following options are
valid:

=over 8

=item * host

Connection host, can be a hostname or IP number. Defaults to C<localhost>.

    host => 'ftp.company.com'
    host => '10.0.0.1'

=item * port

Connection port, default to C<25>.

    port => 25

=item * timeout

Connection timeout, defaults to 60.

    timeout => 60

=item * log

Any object that supports C<debug>, C<info>, C<error> and C<warn>.

    log => Log::Log4perl->get_logger('Authen::Simple::SMTP')

=back

=item * authenticate( $username, $password )

Returns true on success and false on failure.

=back

=head1 SEE ALSO

L<Authen::Simple>.

L<Net::SMTP>.

=head1 AUTHOR

Christian Hansen C<ch@ngmedia.com>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut
