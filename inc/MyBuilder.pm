################################################################################
#
# $Id$
#
# linz_bde_loader -  LINZ BDE loader for PostgreSQL
#
# Copyright 2011 Crown copyright (c)
# Land Information New Zealand and the New Zealand Government.
# All rights reserved
#
# This program is released under the terms of the new BSD license. See the 
# LICENSE file for more information.
#
################################################################################
package inc::MyBuilder;

use base qw(Module::Build);

use Config;
use File::Spec;
use File::Basename;

sub WIN32 () { $^O eq 'MSWin32' }

my $PACKAGE_DIR = 'bernese52';

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->_set_extra_install_paths();
    return $self;
}

sub resume
{
    my $class = shift;
    my $self = $class->SUPER::resume(@_);
    $self->_set_extra_install_paths();
    return $self;
}

sub find_conf_files
{
    shift->_find_files('conf', 'conf');
}

#sub process_script_files {
#    my $self = shift;
#    my $files = $self->find_script_files;
#    return unless keys %$files;
#
#    my $script_dir = File::Spec->catdir($self->blib, 'script');
#    File::Path::mkpath( $script_dir );
#  
#    foreach my $filepath (keys %$files) {
#        my $file = File::Basename::basename($filepath);
#        if ( !WIN32 )
#        {
#            next if $file =~ /^(.*)\.bat$/i;
#            $file =~ s/\.PL$//i;
#        }
#        my $to_file = File::Spec->catfile($script_dir, $file);
#
#        my $result = $self->copy_if_modified(
#            from    => $filepath, 
#            to      => $to_file, 
#            flatten => 'flatten'
#        ) || next;
#        $self->fix_shebang_line($result) unless $self->is_vmsish;
#        $self->make_executable($result);
#    }
#}


sub _set_extra_install_paths
{
    my $self = shift;
    my $prefix = $self->install_base || $self->prefix || $Config::Config{'prefix'} || '';
    my $sysconfdir =  $prefix eq '/usr' ? '/etc' : File::Spec->catdir($prefix, 'etc');
    $self->install_path('conf' => File::Spec->catdir($sysconfdir,$PACKAGE_DIR));
}

sub _find_files
{
    my ($self, $type, $dir) = @_;
    
    if (my $files = $self->{properties}{"${type}_files"}) {
      return { map $self->localize_file_path($_), %$files };
    }
  
    return {} unless -d $dir;
    return { map {$_, $_}
        map $self->localize_file_path($_),
        grep !/\.\#/,
        @{ $self->rscan_dir($dir, qr{\.$type$}) } };
}

1;
