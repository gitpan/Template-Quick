package Template::Quick;
use strict;
use warnings;
use CGI::QuickApp qw(init translate);
require Exporter;
use vars qw($tmp $DefaultClass @EXPORT_OK @ISA $style $mod_perl);
@ISA                         = qw(Exporter);
@Template::Quick::EXPORT     = qw(initTemplate appendHash Template initArray);
%LZE::TabWidget::EXPORT_TAGS = ('all' => [qw(initTemplate appendHash Template initArray  )]);
$Template::Quick::VERSION    = '0.27';
$DefaultClass                = 'Template::Quick' unless defined $Template::Quick::DefaultClass;
our %tmplate;
$style = 'Crystal';
$mod_perl = ($ENV{MOD_PERL}) ? 1 : 0;

=head1 NAME

Template::Quick.pm

=head1 SYNOPSIS

        use Template::Quick;

        $temp = new Template::Quick( {path => "./", template => "template.html"});

        @data = (

                {name => 'Header'},

                {name => 'link', text => "Website", href => "http://lindnerei.de"},

                {name => 'link', text => "Cpan", href => "http://search.cpan.org~lze"},

                {name => 'Footer'}

        );

        print $temp->initArray(\@data);

        template.html:

        [Header]
        A simple text.<br/>
        [/Header]
        [link]
        <a href="[href/]">[text/]</a>
        [/link]
        [Footer]
        <br/>example by [tr=firstname/] Dirk  [tr=name/] Lindner
        [/Footer]


=head2 new

see SYNOPSIS

=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {};
        bless $self, ref $class || $class || $DefaultClass;
        $self->initTemplate(@initializer) if(@initializer);
        return $self;
}

=head2 initTemplate 

       %template = (

                path     => "path",

                style    => "style", #defualt is Crystal

                template => "index.html",

       );

       initTemplate(\%template);

=cut

sub initTemplate {
        init() unless $mod_perl;
        my ($self, @p) = getSelf(@_);
        my $hash = $p[0];
        $DefaultClass = $self;
        use Fcntl qw(:flock);
        use Symbol;
        my $fh = gensym;
        $style = $hash->{style} if defined $hash->{style};
        my $file = "$hash->{path}/$style/$hash->{template}";
        open $fh, "$file" or warn "$!: $file";
        seek $fh, 0, 0;
        my @lines = <$fh>;
        close $fh;
        my ($text, $o);

        for(@lines) {
                $text .= chomp $_;
              SWITCH: {
                        if($_ =~ /\[([^\/|\]]+)\]([^\[\/\1\]]*)/) {
                                $tmplate{$1} = $2;
                                $o = $1;
                                last SWITCH;
                        }
                        if(defined $o) {
                                if($_ =~ /[^\[\/$o\]]/) {
                                        $tmplate{$o} .= $_;
                                        last SWITCH;
                                }
                        }
                }
        }
        $self->initArray($p[1]) if(defined $p[1]);
}

=head2 Template()

see initTemplate

=cut

sub Template {
        my ($self, @p) = getSelf(@_);
        return $self->initArray(@p);
}

=head2 appendHash()

appendHash(\%hash);

=cut

sub appendHash {
        my ($self, @p) = getSelf(@_);
        my $hash = $p[0];
        my $text = $tmplate{$hash->{name}};
        foreach my $key (keys %{$hash}) {
                if(defined $text && defined $hash->{$key}) {

                        if(defined $key && defined $hash->{$key}) {
                                $text =~ s/\[($key)\/\]/$hash->{$key}/g;
                                $text =~ s/\[tr=(\w*)\/\]/translate($1)/eg;
                        }
                }
        }
        return $text;
}

=head2 initArray()

=cut

sub initArray {
        my ($self, @p) = getSelf(@_);
        my $tree = $p[0];
        $tmp = undef if(defined $tmp);
        for(my $i = 0 ; $i < @$tree ; $i++) {
                $tmp .= $self->appendHash(\%{@$tree[$i]});
        }
        return $tmp;
}

=head2 getSelf()

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'Template::Quick');
        return (defined($_[0]) && (ref($_[0]) eq 'Template::Quick' || UNIVERSAL::isa($_[0], 'Template::Quick'))) ? @_ : ($Template::Quick::DefaultClass->new, @_);
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;

