package Dist::Zilla::Plugin::GitHub::RequireGreenBuild;

use Moose;
extends 'Dist::Zilla::Plugin::GitHub';
with qw(
  Dist::Zilla::Role::BeforeRelease
  Dist::Zilla::Role::Git::Repo
);
use HTTP::Tiny;
use List::Util qw(first);
use namespace::clean;

our $VERSION = '0.01';

sub before_release {
  my $self = shift;

  # What is the "HEAD" commit that we're attempting to release?
  my ($head_sha) = $self->git->rev_parse('HEAD');

  # What GitHub repo should we be querying?
  my $repo_name = $self->_get_repo_name;
  unless ($repo_name) {
    $self->log('Unable to determine GitHub repo; cannot check GitHub Actions for a green build');
    return;
  }

  # Dig through the GitHub Actions run history, to find the most recent run for
  # our HEAD sha.
  #
  # Query the results one page at a time, as the response sizes are LARGE and
  # we're hoping/expecting that you're doing a release close to the point in
  # time when you ran the build.
  my $per_page = 50;
  my $page     = 1;
  my $http     = HTTP::Tiny->new;
  $self->log_debug("Checking GitHub Actions for successful run of $head_sha");
  while (1) {
    my $url = $self->api . "/repos/$repo_name/actions/runs?per_page=$per_page&page=$page";
    my $res = $http->request('GET', $url, { headers => $self->_auth_headers });
$self->log_debug($url);

    my $data = $self->_check_response($res);
    unless ($data) {
      $self->log_fatal('Unable to query GitHub Actions');
    }

    # ... were there any Workflow Runs?
    my $workflows = $data->{workflow_runs};
    unless ($workflows && @{$workflows}) {
      $self->log_fatal("Unable to find successful GitHub Actions workflow run for $head_sha");
    }

    # ... were any of those Workflow Runs for this HEAD?  If not, get next page.
    my $run = first { $_->{head_sha} eq $head_sha } @{$workflows};
    unless ($run) {
      $page++;
      next;
    }
    $self->log_debug("found workflow runs for this SHA");

    # ... was the Workflow Run complete?
    unless ($run->{status} eq 'completed') {
      my $build_url = $run->{html_url};
      $self->log_fatal("GitHub Actions workflow incomplete; see $build_url");
    }

    # ... was the Workflow Run successful?
    unless ($run->{conclusion} eq 'success') {
      my $build_url = $run->{html_url};
      $self->log_fatal("GitHub Actions workflow unsuccessful; see $build_url");
    }

    # Looks good!
    $self->log('GitHub Actions run successful');
    last;
  }
}

__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Dist::Zilla::Plugin::GitHub::RequireGreenBuild - Require a successful GitHub Actions workflow run

=head1 SYNOPSIS

  Configure Git with your GitHub login name:

    $ git config --global github.user YourLoginUsername

  then in your dist.ini:

    [GitHub::RequireGreenBuild]

=head1 DESCRIPTION

This C<Dist::Zilla> plugin checks your GitHub Actions for a successful run,
before allowing a release.

e.g. until we can determine that you have a green build for a GitHub Actions run
against C<HEAD>, you're not allowed to release.

=head1 AUTHOR

Graham TerMarsch (cpan@howlingfrog.com)

=head1 COPYRIGHT

Copyright (C) 2020-, Graham TerMarsch.  All Rights Reserved.

This is free software; you can redistribute it and/or modify it under the same
license as Perl itself.

=head1 SEE ALSO

=over

=item L<Dist::Zilla>

=back

=cut
