# A heuristic/active learning approach to selecting samples for phylodynamic inference of viral importations

Mengyan Zhang<sup>1</sup>, Bernardo Gutierrez<sup>2,3</sup>, Rhys P.D. Inward<sup>2</sup>, Seth Flaxman<sup>1,†</sup>, Moritz U.G. Kraemer<sup>2,4,†</sup>

1.	Department of Computer Science, University of Oxford, Oxford, UK
2.	Department of Biology, University of Oxford, Oxford, UK
3.	Colegio de Ciencias Biologicas y Ambientales, Universidad San Francisco de Quito USFQ, Quito, Ecuador
4.	Pandemic Sciences Institute, University of Oxford, Oxford, UK


## Repository structure and general notes
The structure of this repository is shown below.  

Currently, the main folder of the repository contains a data set for a simulated epidemic in two separate locations, with direct flow of patients from the 'source location' (also called Deme 1) to the location of interest where we are performing the analysis (also called Deme 2). Details about the simulation are available in this [`GitHub repository`](https://github.com/rhysinward/sampling_phylodyanmics/tree/main). 

```
AL_genomic_importation_sampling/
├── epidemic_simulation_data
│   ├── genetic_distance_estimator.R
│   └── get_me_distances.sh
└── README.md
```

## Generation of pairwise genetic distance matrices from simulated genome sequences
The heuristic is based on various features attached to individual genome sequences, including the genetic distance of each sequence to every other sequence in the data sets. These files cannot be provided via GitHub as they are too large to be hosted in this platform (140.1 MB for a file in symmetric matrix form and 1.33 GB for a file in long data frame form). Therefore these files can be estimated locally from the simulated genetic sequences and metadata files following these steps (these are based on a Mac/Linux environment):

### 1. Clone the GitHub repository in your local machine.
This can be done by navigating in the terminal to the local folder where you want to clone the repository and typing:


```bash
git clone git@github.com:BernardoGG/AL_genomic_importation_sampling.git
```

Please note you will need a valid GitHub account and an active SSH key (more information about GitHub authentication via SSH [`here`](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/about-ssh)).

### 2. Navigate to the [`epidemic_simulation_data`](epidemic_simulation_data/) folder.
The files required to run this operation are not on the repository main folder. Type in the terminal:

```bash
cd epidemic_simulation_data
```

The user may need to perform an additional operation to download the large file which contains the simulated genetic sequences. To do this, mmak sure you have the latest version of [`GitHub LFS`](https://github.com/git-lfs/git-lfs) installed and type:

```bash
git lfs pull
```

### 3. Grant permission to execute the script that generates the pairwise genetic distances.
This operation is run from a bash script which provides a control step and executes an R script within the same directory. To run the bash script, provide permission to execute by typing:

```bash
chmod +x get_me_genetic_distances.sh
```

### 4. Execute the bash script that generates the matrices.
You can run the scripts by typing

```bash
sh get_me_genetic_distances.sh
```

This will prompt an interactive warning on your terminal stating that the operation may take a few hours to run, and will require you to ackowledge this (i.e., type 'y' or 'yes') to proceed. The script will then activate the accompanying genetic_distance_estimator.R file which produces the pairwise genetic distance matrices and saves them in RData format.