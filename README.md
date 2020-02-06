# TakeOutClusters
Ruby refresher to compute clusters from Google TakeOut Data

## Introduction
This application is composed of 2 main files and a test file  *position_tools* contains a set of classes defining a 
dynamically defined point together with a segment made out of two points and a cluster or group of points.
*compute_clusters* uses the classes from *position_tools* to compute speed statistics between consecutive points.

The point contents are dynamic, a factory class is provisioned with:
 * A key mapping between data and field names
 * A data transform for a subset of the fields
 * A formatter for each field
 * A time_lapse method between two points
 * A distance method between two points
 
The distance between and time_lapse between two points also depend on the fields present in the point.

The test file *test_position* shows the utilisation of the dynamic point together with distance, time_lapse and speed
for a segment. 

The same strategy of behaviour injection is leveraged for the cluster class, where the method to compute the centroid 
and the criteria for inclusion of a point in a cluster are passed as two lambda parameters.

The code may not be very idiomatic in terms of ruby and there are many betters ways of achieving better performance and
correct clustering. It did serve however as a Ruby refresher and to acquaint myself with the basics of meta-programming,
and lambdas in Ruby.

Pull requests for fixing WTFs welcome.

## Running this applications

Command sequence to install and run this sample application

    git clone git@github.com:jamiguet/TakeOutClusters.git
    bundler install
    bundler exec rake test
    
    bundler exec rake sample_data:fetch
    bundler exec rake run
    bundler exec rake sample_data:clean


## TODOs

### Application 
 - [X] Specify data file from arguments
 - [X] Add Point cluster
 - [X] Add belongs / rejects point cluster
 
 ### Position tools lib
 
 - [X] Make segment distance parameterizable according to point definition

### Rakefile
 - [X] Run tests
 - [X] Download data from given url
 - [X] run the application
