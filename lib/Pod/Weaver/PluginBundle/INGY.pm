use strict;
use warnings;
package Pod::Weaver::PluginBundle::INGY;
# ABSTRACT: INGY's default Pod::Weaver config

=head1 OVERVIEW

Roughly equivalent to:

=for :list
* C<@Default>
* C<-Transformer> with L<Pod::Elemental::Transformer::List>

=cut

use Pod::Weaver::Config::Assembler;
sub _exp { Pod::Weaver::Config::Assembler->expand_package($_[0]) }

sub mvp_bundle_config {
  my @plugins;
  push @plugins, (
    [ '@INGY/CorePrep',    _exp('@CorePrep'), {} ],
    [ '@INGY/Name',        _exp('Name'),      {} ],
    [ '@INGY/Version',     _exp('Version'),   {} ],

    [ '@INGY/Prelude',     _exp('Region'),  { region_name => 'prelude'     } ],
    [ '@INGY/Synopsis',    _exp('Generic'), { header      => 'SYNOPSIS'    } ],
    [ '@INGY/Description', _exp('Generic'), { header      => 'DESCRIPTION' } ],
    [ '@INGY/Overview',    _exp('Generic'), { header      => 'OVERVIEW'    } ],

    [ '@INGY/Stability',   _exp('Generic'), { header      => 'STABILITY'   } ],
  );

  for my $plugin (
    [ 'Attributes', _exp('Collect'), { command => 'attr'   } ],
    [ 'Methods',    _exp('Collect'), { command => 'method' } ],
    [ 'Functions',  _exp('Collect'), { command => 'func'   } ],
  ) {
    $plugin->[2]{header} = uc $plugin->[0];
    push @plugins, $plugin;
  }

  push @plugins, (
    [ '@INGY/Leftovers', _exp('Leftovers'), {} ],
    [ '@INGY/postlude',  _exp('Region'),    { region_name => 'postlude' } ],
    [ '@INGY/Authors',   _exp('Authors'),   {} ],
    [ '@INGY/Legal',     _exp('Legal'),     {} ],
    [ '@INGY/List',      _exp('-Transformer'), { 'transformer' => 'List' } ],
  );

  return @plugins;
}

1;
