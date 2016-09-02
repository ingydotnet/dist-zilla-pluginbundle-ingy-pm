package Dist::Zilla::PluginBundle::INGY;

use Moose;
use Dist::Zilla 2.100922; # TestRelease
with 'Dist::Zilla::Role::PluginBundle::Easy';
with 'Dist::Zilla::Role::PluginBundle::Config::Slicer';
with 'Dist::Zilla::Role::PluginBundle::PluginRemover';
with 'Dist::Zilla::Role::BundleDeps';


use Dist::Zilla::PluginBundle::Basic;
use Dist::Zilla::PluginBundle::Filter;
use Dist::Zilla::PluginBundle::Git;

has manual_version => (
  is      => 'ro',
  isa     => 'Bool',
  lazy    => 1,
  default => sub { $_[0]->payload->{manual_version} },
);

has major_version => (
  is      => 'ro',
  isa     => 'Int',
  lazy    => 1,
  default => sub { $_[0]->payload->{version} || 0 },
);

has is_task => (
  is      => 'ro',
  isa     => 'Bool',
  lazy    => 1,
  default => sub { $_[0]->payload->{task} },
);

has github_issues => (
  is      => 'ro',
  isa     => 'Bool',
  lazy    => 1,
  default => sub { $_[0]->payload->{github_issues} },
);

sub configure {
  my ($self) = @_;

  $self->add_plugins('Git::GatherDir');
  $self->add_plugins('CheckPrereqsIndexed');
  $self->add_plugins('CheckExtraTests');
  $self->add_bundle('@Filter', {
    '-bundle' => '@Basic',
    '-remove' => [ 'GatherDir', 'ExtraTests' ],
  });

  $self->add_plugins('AutoPrereqs');

  unless ($self->manual_version) {
    if ($self->is_task) {
      my $v_format = q<{{cldr('yyyyMMdd')}}>
                   . sprintf('.%03u', ($ENV{N} || 0));

      $self->add_plugins([
        AutoVersion => {
          major     => $self->major_version,
          format    => $v_format,
          time_zone => 'America/New_York',
        }
      ]);
    } else {
      $self->add_plugins([
        'Git::NextVersion' => {
          version_regexp => '^([0-9]+\.[0-9]+(?:\.[0-9]+)?)$',
        }
      ]);
    }
  }

  $self->add_plugins(qw(
    ReadmeFromPod
    OurPkgVersion
    MetaConfig
    MetaJSON
    NextRelease
  ),
  # XXX Fix for ingy style
  # Test::ChangesHasContent
  qw(
    PodSyntaxTests
    Test::Compile
    Test::ReportPrereqs
  ));

  $self->add_plugins(
    [ Prereqs => 'TestMoreWithSubtests' => {
      -phase => 'test',
      -type  => 'requires',
      'Test::More' => '0.96'
    } ],
  );

  $self->add_plugins(
    [ GithubMeta => {
      ':version' => '0.18',
      user   => 'ingydotnet',
      remote => [ qw(origin) ],
      issues => $self->github_issues,
    } ],
  );

  $self->add_bundle('@Git' => {
    tag_format => '%v',
    remotes_must_exist => 0,
    push_to    => [
      'origin :',
    ],
  });
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=encoding utf8

=head1 NAME

Dist::Zilla::PluginBundle::INGY - BeLike::INGY when you build your dists

=head1 SYNOPSIS

In your F<dist.ini>:

    [@INGY]

=head1 DESCRIPTION

This is the plugin bundle that INGY uses.  It is more or less equivalent to:

  [Git::GatherDir]
  [CheckPrereqsIndexed]
  [CheckExtraTests]

  ; @Basic without GatherDir and ExtraTests
  [@Filter]
  -bundle = @Basic
  -remove = GatherDir
  -remove = ExtraTests

  [AutoPrereqs]
  [Git::NextVersion]
  version_regexp = ^([0-9]+\.[0-9]+(?:\.[0-9]+)?)$
  {ReadmeFromPod}
  [OurPkgVersion]
  [MetaConfig]
  [MetaJSON]
  [NextRelease]

  ;[Test::ChangesHasContent]
  [PodSyntaxTests]
  [Test::Compile]
  [Test::ReportPrereqs]

  [Prereqs / TestMoreWithSubtests]
  -phase = test
  -type = requires
  Test::More = 0.96

  [GithubMeta]
  user = ingydotnet
  remote = origin
  ;issues =

  [@Git]
  tag_format = %v
  remotes_must_exist = 0
  ;push_to = origin

The bundle implements the roles
L<Config::Slicer|Dist::Zilla::Role::PluginBundle::Config::Slicer>
(to easily set config options in bundled plugins) and
L<PluginRemover|Dist::Zilla::Role::PluginBundle::PluginRemover>
(more convenient than wrapping with
L<[@Filter]|Dist::Zilla::PluginBundle::Filter>).

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2013. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
