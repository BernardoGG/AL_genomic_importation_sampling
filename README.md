# A heuristic/active learning approach to selecting samples for phylodynamic inference of viral importations

Mengyan Zhang<sup>1</sup>, Bernardo Gutierrez<sup>2,3</sup>, Rhys P.D. Inward<sup>2</sup>, Joseph L.H. Tsui<sup>2</sup>, Seth Flaxman<sup>1,†</sup>, Moritz U.G. Kraemer<sup>2,4,†</sup>

1.	Department of Computer Science, University of Oxford, Oxford, UK
2.	Department of Biology, University of Oxford, Oxford, UK
3.	Colegio de Ciencias Biologicas y Ambientales, Universidad San Francisco de Quito USFQ, Quito, Ecuador
4.	Pandemic Sciences Institute, University of Oxford, Oxford, UK

## Project summary
Phylodynamic estimates of the number and timing of importations of a pathogen into a novel geographical location reauires the analysis of genome sequences collected in the location of interest and a set of sequences from possible source locations for the importation of the pathogen. Given the computational costs of running phylodynamic analyses with large data sets, there is a need for systems to identify a minimum set of 'background' sequences which are sufficient to accurately identify introduction events of the pathogen. By using a simulated epidemic between two geographical locations linked by human mobility (simulating a UK/non-UK scenario), the purpose of the active learning approach presented in this repository is to start with a full data set (which would result in a phylogenetic tree that shows all viral introductions, A), identify the domestic sequences for which we strongly believe that the infection occurred abroad (i.e., genomes from infected patients with a recent travel history outside of the UK, B) and label the international sequences to identify the minimum set of sequences which would result in a phylogenetic tree that shows the same number of introductions as the tree with the full data set (C).

![sampling_data_set_trees_schematic](https://github.com/BernardoGG/AL_genomic_importation_sampling/assets/19906478/6b792bda-cd3f-47f3-9deb-574c4b5c4a49)

In principle, the active learning pipeline would attempt to label non-UK genomes as likely cases of epidemiologically linked sequences with other UK sequences; in practice, this would mean adding a 'travel history' label which we're using as the proxy for the epidemiological link as such:

![target_samples_schematic-01](https://github.com/BernardoGG/AL_genomic_importation_sampling/assets/19906478/8fef3038-a574-4341-b9cb-8460fde41a0a)

- UK sequences with a travel history are labelled observations.
- UK sequences without a travel history are data points where the label is unknown.
- Non-UK sequences provide contextual information but are labelled as they are not part of the pool of sequences chosen to be labelled (i.e., we know these are not part of the UK).
- All features (i.e., covariates) can be queried to determine which of these are useful in classifying unlabelled sequences.

## Repository structure and general notes
The structure of this repository is shown below.

Currently, the main folder of the repository contains a data set for a simulated epidemic in two separate locations, with direct flow of patients from the 'source location' (also called Deme 1) to the location of interest where we are performing the analysis (also called Deme 2). Details about the simulation are available in this [`GitHub repository`](https://github.com/rhysinward/sampling_phylodyanmics/tree/main). 

```
AL_genomic_importation_sampling/
├── active_learning_code
│   ├── al_model.ipynb
│   └── al_model_no_genetic_distances.ipynb
├── epidemic_simulation_data
│   ├── genetic_distance_matrices
│   ├── plots
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

The user may need to perform an additional operation to download the large file which contains the simulated genetic sequences. To do this, make sure you have the latest version of [`GitHub LFS`](https://github.com/git-lfs/git-lfs) installed and type:

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

This will prompt an interactive warning on your terminal stating that the operation may take a few hours to run, and will require you to ackowledge this (i.e., type 'y' or 'yes') to proceed. The script will then activate the accompanying genetic_distance_estimator.R file which produces the pairwise genetic distance matrices and saves them in RData format in the [`genetic_distance_matrices`](epidemic_simulation_data/genetic_distance_matrices) folder (which remains empty in this repository).
