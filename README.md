# Oslo-method-normalization-procedure-using-bayesian-inference-technique


## Description
Bayesian framework using Metropolis–Hastings MCMC to quantify statistical and systematic uncertainties in Oslo-method nuclear level densities and γ-ray strength functions, with uncertainty propagation to the  neutron-capture cross section and astrophysical reaction rate.


## Setup Instructions
1. Clone the repository:
   ```bash
      git clone https://github.com/amalseb07/Oslo-method-normalization-procedure-using-bayesian-inference-technique.git
  

2. Create and Activate a python environment
   - micrmomaba create -n Bayes_OSlo
   - micromamba activate Bayes_OSlo
     
3. Install dependencies
   - pip install -r requirements.txt   


## Step 0: Data and model preperation.
For this work, we need both data from the experement and also the default models from TALYS ( Here I have used TALYS 2.0 but one can easily adopt this to other TALYS versions)

### Experimental data
You need 3 pieces of experimental data : 
1. The unnormalized experimental GSF of the isotope ( here 100Zr).
2. The unnormalized experimental NLD of the isotope ( here 100Zr).
3. The experimental GSF to which you wish to normalize the data to (here 97Zr).

These are found in input_data folder as gsf_100Zr_baseline_full.csv, gsf_97Zr.csv and 100Z_ld.csv. The rholev.txt is the known levels of 100Zr at low-excitation enegies. You can replace it with your data in the same format. 

### Base Model for GSF and NLD
1. For GSF , I have chosen strength =3 for E1 component and strengthM1 = 1 with talys parameters upbende=0, ubendc =0 and       ftable =1. This constitute the base model on which modifications are done to compare with experimental data . It is          stored as a .pkl file in interp_data. This has the same format as the GSF table obtained from output.dat from TALYS2.0.
2. For NLD , I have ldmodel =5 with ctable , ptable values set to 0. This constitute the base model on which modifications      are done to compare with experimental data . It is stored as a .pkl file in interp_data. This has the same format as the     NLD table obtained from output.dat from TALYS2.0. ( Note: this .pkl file is combination of many .pkl files with ptable       varied across multiple values. This is because in the actual MCMC steps , we need interpolation of NLD values and to make    interpolation smooth , many values are required.)


