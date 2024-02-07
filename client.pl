#!/usr/bin/perl
#Author: Alessandro Valenti

use strict;
use warnings;
use IO::Socket::INET;

my $host = '127.0.0.1';
my $port = 12345;

# Create a TCP socket and connect to the server
my $socket = new IO::Socket::INET (
    PeerHost => $host,
    PeerPort => $port,
    Proto    => 'tcp',
) or die "Error in socket creation: $!\n";

print "Connected to the server on $host:$port\n";

# Accept input from the command-line interface
print "Input Insert or Query (I/Q): ";
my $operation = <STDIN>;
chomp $operation;  # Remove the newline character
if ($operation eq 'I') { # Insert data
    print "Input timestamp: ";
    my $timestamp = <STDIN>;
    chomp $timestamp;  # Remove the newline character
    print "Input price: ";
    my $price = <STDIN>;
    chomp $price;  # Remove the newline character
    my $op = unpack("H2", $operation);
    my $packed_data = pack('N', $timestamp); 
    my $hex_timestamp = unpack('H8', $packed_data);
    $packed_data = pack('N', $price); 
    my $hex_price = unpack('H8', $packed_data);
    my $tosend = $op . $hex_timestamp . $hex_price;
    print "Hex representation: $tosend\n";
    $socket->send($tosend);
    # Close the socket
    $socket->close();
}
elsif ($operation eq 'Q') { # Query data
    my $op = unpack("H2", $operation);
    print "Input mintime: ";
    my $mintime = <STDIN>;
    chomp $mintime;  # Remove the newline character
    my $packed_data = pack('N', $mintime);
    my $hex_mintime = unpack('H8', $packed_data);

    print "Input maxtime: ";
    my $maxtime = <STDIN>;
    chomp $maxtime;  # Remove the newline character
    $packed_data = pack('N', $maxtime);
    my $hex_maxtime = unpack('H8', $packed_data);
    my $tosend = $op . $hex_mintime . $hex_maxtime;
    print "Hex representation: $tosend\n";
    $socket->send($tosend);
    my $data = "";
    $socket->recv($data, 1024);
    print "Received data: $data\n";
    $socket->close();
}
else {
    print "Invalid input\n";
}
