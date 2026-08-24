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
1. For GSF , I have chosen strength =3 for E1 component and strengthM1 = 1 with talys parameters upbende=0, ubendc =0 and ftable =1. This constitute the base model on which modifications are done to compare with experimental data . It is stored as a master_base_gsf.pkl file in interp_data. This has the same format as the GSF table obtained from output.dat from TALYS2.0. Here, modifications mean tuning the parameters upbende, upbendc and ftable in TALYS2.0.
2. For NLD , I have ldmodel =5 with ctable , ptable values both set to 0. This constitute the base model on which modifications are done to compare with experimental data . It is stored as a master_base_ld_p.pkl and master_base_ld_n.pkl file in interp_data corresponding to pos. This has the same format as the     NLD table obtained from output.dat from TALYS2.0 .Here modifications mean tuning the parameters ctable and ptable in TALYS2.0.( Note: this .pkl file is combination of many .pkl files with ptable       varied across multiple values. This is because in the actual MCMC steps , we need interpolation of NLD values and to make    interpolation smooth , many values are required.)

## Step 1: Constraining the γSF within the Bayesian framework

- In this step we get the set of all  tuned model parameters such that they represent the GSF of 97Zr at high energies while after the transformation preserve the structure of the actual experimental data i.e 100Zr. This is how both normalization and uncertainty quantification is done in a single step. More details on the math behind it can be found at in the paper ......

1. Take the jupyter notebook gsf.ipynb and add both your experimental GSF data ( here gsf_100Zr_baseline_full.csv) and the data to which you want to normalize to ( here gsf_97Zr.csv) in the respective cells
2. Also add the master_base_gsf.pkl file in the cell respective cell (Pulling the base data of gsf and interpolation to the experimental energy).
3. Add the necessary changes to the variables as you go.
4. In the prior definition ( cell -Likelihood and prior definition starts here)  , add the conditions on prior as necessary.
5. In the cell titled " Running the Full MCMC Setup" , you can spectify the initial starting point of the walker, prior mean , prior standard deviation, and also stepsize of each paramter.
6. The ideal acceptance percentage is around 30-50 but it can vary from problem to problem.
7. It is important that in the cell titled "Drawing different chains in MCMC" , you see a convergence of the each individual parameter. This is the proof that the MCMC has finally settled on a set of values . If the trend is such that it is increasing or decreasing , it means that it needs to be tuned again ( like stepsize , prior means, prior widths need to be reconsidered)
8. If everything goes well , run down the cells where you can see the corner plots and also the bands produced as a result of normalization and uncertainty quantification
   



