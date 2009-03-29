package LJ::Setting::ImagePlaceholders;
use base 'LJ::Setting';
use strict;
use warnings;

sub should_render {
    my ($class, $u) = @_;

    return !$u || $u->is_community ? 0 : 1;
}

sub helpurl {
    my ($class, $u) = @_;

    return "image_placeholders_full";
}

sub label {
    my $class = shift;

    return $class->ml('setting.imageplaceholders.label');
}

sub option {
    my ($class, $u, $errs, $args) = @_;
    my $key = $class->pkgkey;

    my $imgplaceholders = $class->get_arg($args, "imgplaceholders") || $u->prop("opt_imagelinks") || "";
    my $imgplaceundef = $class->get_arg( $args, "imgplaceundef" ) || $u->prop( "opt_imageundef" ) || "";

    my ($maxwidth, $maxheight) = (0, 0);
    ($maxwidth, $maxheight) = ($1, $2)
        if $imgplaceholders =~ /^(\d+)\|(\d+)$/;

    my $is_stock = {
        "320|240" => 1,
        "640|480" => 1,
        "0|0" => 1,
        "" => 1,
    }->{$imgplaceholders};
    my $extra = $class->ml('setting.imageplaceholders.option.select.custom', { width => $maxwidth, height => $maxheight })
        unless $is_stock;

    my @options = (
        "0" => $class->ml('setting.imageplaceholders.option.select.none'),
        "0|0" => $class->ml('setting.imageplaceholders.option.select.all'),
        "320|240" => $class->ml('setting.imageplaceholders.option.select.medium', { width => 320, height => 240 }),
        "640|480" => $class->ml('setting.imageplaceholders.option.select.large', { width => 640, height => 480 }),
        $extra ? ("$maxwidth|$maxheight" => $extra) : ()
    );

    my $ret = "<label for='${key}imgplaceholders'>" . $class->ml('setting.imageplaceholders.option') . "</label> ";
    $ret .= LJ::html_select({
        name => "${key}imgplaceholders",
        id => "${key}imgplaceholders",
        selected => $imgplaceholders,
    }, @options);

    # Option for undefined-size images. Might want to be magicked into only displaying when placeholders are set for other than all/none

    my @optionundef = (
        0 => $class->ml( 'setting.imageplaceholders.option.undef.small' ),
        1 => $class->ml( 'setting.imageplaceholders.option.undef.large' )
    );

    $ret .= "<br /><label for='${key}imgplaceundef'>" . $class->ml( 'setting.imageplaceholders.option.undef' ) . "</label> ";
    $ret .= LJ::html_select({
        name => "${key}imgplaceundef",
        id => "${key}imgplaceundef",
        selected => $imgplaceundef,
    }, @optionundef);


    my $errdiv = $class->errdiv($errs, "imgplaceholders");
    $errdiv .= $class->errdiv( $errs, "imgplaceundef" );
    $ret .= "<br />$errdiv" if $errdiv;

    return $ret;
}

sub error_check {
    my ($class, $u, $args) = @_;
    my $val = $class->get_arg($args, "imgplaceholders");

    $class->errors( imgplaceholders => $class->ml('setting.imageplaceholders.error.invalid') )
        unless !$val || $val =~ /^(\d+)\|(\d+)$/;

    return 1;
}

sub save {
    my ($class, $u, $args) = @_;
    $class->error_check($u, $args);

    my $val = $class->get_arg($args, "imgplaceholders");
    $u->set_prop( opt_imagelinks => $val );
    $val = $class->get_arg( $args, "imgplaceundef" );
    $u->set_prop( opt_imageundef => $val );

    return 1;
}

1;
