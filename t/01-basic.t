use strict;
use warnings;
use Test::More tests => 5;
use Catalyst::Utils;

{
    package Catalyst::Model::SomeModel;
    use Moose;
    extends 'Catalyst::Model';
    with 'CatalystX::Component::Traits';

    package Catalyst::TraitFor::Model::SomeModel::Foo;
    use Moose::Role;
    has 'foo' => (is => 'ro');

    package MyApp::Model::MyModel;
    use base 'Catalyst::Model::SomeModel';
    use Scalar::Util qw/blessed/;

    __PACKAGE__->config(
        traits => ['Foo', 'Bar'],
        foo => 'bar'
    );

    sub find_app_class {
        my $self = shift;
        Catalyst::Utils::class2appclass(blessed($self) || $self);
    }

    package MyApp::TraitFor::Model::SomeModel::Bar;
    use Moose::Role;
    has 'bar' => (is => 'ro');
}

my $app_class = 'MyApp';

ok((my $instance = MyApp::Model::MyModel->COMPONENT(
        $app_class,
        { bar => 'baz' }
    )),
    'created a component instance');

ok(($instance->does('Catalyst::TraitFor::Model::SomeModel::Foo')),
    'instance had parent ns trait loaded from component config');

ok(($instance->does('MyApp::TraitFor::Model::SomeModel::Bar')),
    'instance had app ns trait loaded from component config');

is $instance->foo, 'bar',
    'trait initialized from component config works';

is $instance->bar, 'baz',
    'trait initialized from app config works';

TODO: {
    local $TODO = "Finding by class name can't work as we're now an anon class...";
    is $instance->find_app_class, 'MyApp', 'Can find app class passing instance';
}

