#!/usr/bin/perl

use strict;
use warnings;
use lib 't/lib';

use Test::Deep;
use Test::Exception;
use Test::More;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::Inventory;
use FusionInventory::Agent::Task::Inventory::Linux::Archs::i386;
use FusionInventory::Agent::Task::Inventory::Linux::Archs::Alpha;
use FusionInventory::Agent::Task::Inventory::Linux::Archs::SPARC;
use FusionInventory::Agent::Task::Inventory::Linux::Archs::MIPS;
use FusionInventory::Agent::Task::Inventory::Linux::Archs::ARM;
use FusionInventory::Agent::Task::Inventory::Linux::Archs::PowerPC;

my %i386 = (
    'linux-686-1' => [
        {
            THREAD       => 1,
            MANUFACTURER => 'Intel',
            NAME         => 'Intel(R) Pentium(R) M processor 1.73GHz',
            CORE         => 1,
            STEPPING     => '8',
            SPEED        => '1730',
            MODEL        => '13',
            FAMILYNUMBER => '6'
        }
    ],
    'linux-686-samsung-nc10-1' => [
        {
            CORE         => '1',
            SPEED        => '1600',
            THREAD       => '2',
            NAME         => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
            MODEL        => '28',
            MANUFACTURER => 'Intel',
            FAMILYNUMBER => '6',
            STEPPING     => '2'
        }
    ],
    'linux-2.6.35-1-core-2-thread' => [
        {
            NAME         => 'Intel(R) Atom(TM) CPU N270   @ 1.60GHz',
            THREAD       => '2',
            SPEED        => '1600',
            STEPPING     => '2',
            CORE         => '1',
            FAMILYNUMBER => '6',
            MANUFACTURER => 'Intel',
            MODEL        => '28'
        }
    ],

# IMPORTANT : this /proc/cpuinfo is _B0RKEN_, physical_id are not correct
# please see bug: #505
    'linux-hp-dl180' => [
        {
            FAMILYNUMBER => 6,
            SPEED        => 2000,
            STEPPING     => 5,
            MANUFACTURER => 'Intel',
            CORE         => '4',
            NAME         => 'Intel(R) Xeon(R) CPU           E5504  @ 2.00GHz',
            MODEL        => 26,
            THREAD       => '1',
        }
    ],
    'toshiba-r630-2-core' => [
        {
            THREAD       => '2',
            NAME         => 'Intel(R) Core(TM) i3 CPU       M 350  @ 2.27GHz',
            CORE         => '2',
            MODEL        => '37',
            STEPPING     => '5',
            SPEED        => '2270',
            MANUFACTURER => 'Intel',
            FAMILYNUMBER => '6'
        }
    ]
);

my %alpha = (
    'linux-alpha-1' => [
        {
            SERIAL => 'JA30502089',
            ARCH   => 'Alpha',
            SPEED  => '1250',
            TYPE   => undef
        }
    ]
);

my %sparc = (
    'linux-sparc-1' => [
        {
            ARCH => 'SPARC',
            TYPE => 'TI UltraSparc IIIi (Jalapeno)'
        },
        {
            ARCH => 'SPARC',
            TYPE => 'TI UltraSparc IIIi (Jalapeno)'
        }
    ]
);

my %arm = (
    'linux-armel-1' => [
        {
            ARCH  => 'ARM',
            TYPE  => 'XScale-80219 rev 0 (v5l)'
        }
    ],
    'linux-armel-2' => [
        {
            ARCH  => 'ARM',
            TYPE  => 'Feroceon 88FR131 rev 1 (v5l)'
        }
    ],
);

my %mips = (
    'linux-mips-1' => [
        {
            NAME => 'R4400SC V5.0  FPU V0.0',
            ARCH => 'MIPS'
        }
    ]
);

my %ppc = (
    'linux-ppc-1' => [
        {
            NAME         => '604r',
            MANUFACTURER => undef,
            SPEED        => undef
        }
    ],
    'linux-ppc-2' => [
        {
            NAME         => 'POWER4+ (gq)',
            MANUFACTURER => undef,
            SPEED        => '1452'
        },
        {
            NAME         => 'POWER4+ (gq)',
            MANUFACTURER => undef,
            SPEED        => '1452'
        }
    ],
    'linux-ppc-3' => [
        {
            NAME         => 'PPC970FX, altivec supported',
            MANUFACTURER => undef,
            SPEED        => '2700'
        },
        {
            NAME         => 'PPC970FX, altivec supported',
            MANUFACTURER => undef,
            SPEED        => '2700'
        }
    ]
);

plan tests =>
    (2 * scalar keys %alpha) +
    (2 * scalar keys %sparc) +
    (2 * scalar keys %arm)   +
    (2 * scalar keys %mips)  +
    (2 * scalar keys %ppc)   +
    (2 * scalar keys %i386);

my $logger    = FusionInventory::Agent::Logger->new(
    backends => [ 'fatal' ],
    debug    => 1
);
my $inventory = FusionInventory::Agent::Inventory->new(logger => $logger);

foreach my $test (keys %i386) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Linux::Archs::i386::_getCPUs(file => $file);
    cmp_deeply(\@cpus, $i386{$test}, "cpus: ".$test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } 'no unknown fields';
}

foreach my $test (keys %alpha) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Linux::Archs::Alpha::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $alpha{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } 'no unknown fields';
}

foreach my $test (keys %sparc) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Linux::Archs::SPARC::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $sparc{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } 'no unknown fields';
}

foreach my $test (keys %mips) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Linux::Archs::MIPS::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $mips{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } 'no unknown fields';
}

foreach my $test (keys %arm) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Linux::Archs::ARM::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $arm{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } 'no unknown fields';
}

foreach my $test (keys %ppc) {
    my $file = "resources/linux/proc/cpuinfo/$test";
    my @cpus = FusionInventory::Agent::Task::Inventory::Linux::Archs::PowerPC::_getCPUsFromProc(file => $file);
    cmp_deeply(\@cpus, $ppc{$test}, $test);
    lives_ok {
        $inventory->addEntry(section => 'CPUS', entry => $_) foreach @cpus;
    } 'no unknown fields';
}