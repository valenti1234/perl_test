#!/usr/bin/perl
#Author: Alessandro Valenti

use strict;
use warnings;
use IO::Socket::INET;
my @array;
my @data_array;


my $port = 12345;

# Create a TCP socket
my $socket = new IO::Socket::INET (
    LocalPort => $port,
    Proto     => 'tcp',
    Listen    => 5,
    Reuse     => 1
) or die "Error in socket creation: $!\n";

print "TCP Server Waiting for client on port $port\n";

while (1) {
    # Waiting for a new client connection
    my $client_socket = $socket->accept();

    # Get information about the client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "Accepted new client connection from: $client_address, $client_port\n";

     # Keep the connection open and handle ongoing communication with the client
    while (1) {
        # Read data from the client
        my $data = "";
        $client_socket->recv($data, 1024);
        last if $data eq "";  # Exit the loop if the client closes the connection
        print "Received data: $data\n";
        my $decoded_operation = pack("H2", $data);
        print "Decoded operation: $decoded_operation\n";
        if ($decoded_operation eq 'I') {
            print "Insert operation\n";
            my $sub =  substr( $data, 2, 8);  # Extract the timestamp from the first 4 bytes of $data);
            my $timestamp = hex($sub);
            print "Timestamp: $timestamp\n";
            $sub =  substr( $data, 10);  # Extract the timestamp from the first 4 bytes of $data);
            my $price = hex($sub);
            print "Price: $price\n";
            my $hash_ref = {timestamp => $timestamp, price => $price};
            push @data_array, $hash_ref;
        }
        elsif ($decoded_operation eq 'Q') {
            print "Query operation\n";
            my $sub =  substr( $data, 2, 8);  # Extract the timestamp from the first 4 bytes of $data);
            my $min_timestamp = hex($sub);
            print "Min Timestamp: $min_timestamp\n";
            $sub =  substr( $data, 10);  # Extract the timestamp from the first 4 bytes of $data);
            my $max_timestamp = hex($sub);
            print "Max timestamp: $max_timestamp\n";


            my @sorted_array = sort { $a->{'timestamp'} <=> $b->{'timestamp'} } @data_array;
            my $sum = 0;
            my $mean = 0;
            
            foreach my $item (@sorted_array) {
                print $item->{'timestamp'} . " " . $item->{'price'} . "\n";
            }
            
            if(@sorted_array > 0) { #check if array is not empty
                foreach my $item (@sorted_array) {
                    if ($item->{'timestamp'} >= $min_timestamp && $item->{'timestamp'} <= $max_timestamp) {
                        $sum += $item->{'price'};
                    }
                }
                $mean = $sum / scalar @sorted_array;
            }
            print "Mean price: $mean\n";
            my  $packed_data = pack('N', $mean); 
            my $hex_mean = unpack('H8', $packed_data);
            print "Hex representation: $hex_mean\n";
            $client_socket->send($hex_mean);
        }
        else {
            print "Invalid operation\n";
        }
    }
}

