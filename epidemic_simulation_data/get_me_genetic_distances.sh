#!/bin/bash

echo "This operation might take several hours to complete. Do you want to continue? (y/yes)"
read -r user_input

if [[ $user_input == "y" || $user_input == "yes" ]]; then
    echo "Generating pairwise genetic distance matrices..."
    Rscript genetic_distance_estimator.R
else
    echo "Pairwise genetic distance matrix estimation canceled."
fi