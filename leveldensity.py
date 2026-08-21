import numpy as np
import matplotlib.pyplot as plt
import scipy
import pandas as pd

df=pd.read_csv("input_data/100Z_ld.csv")
df_new = df.copy()

# convert to python arrays
energy=df_new["energy"].values # as numpy array
ld=df_new["ld"].values 
error=df_new["errors"].values


# energy taken only from the last discrete in RIPLE-3
energy =energy[3:]
ld= ld[3:]
error= error[3:]



# pulling master base data of NLD for interpolation
df_p =pd.read_pickle("interp_data/master_base_ld_p.pkl")
df_n = pd.read_pickle("interp_data/master_base_ld_n.pkl")


# Input functions for likelihood

def model_ld_100(j,params):

    ctable_vis= 0
    ptable_vis= 0
    
    ctable = params[0]+ctable_vis
    ptable = params[1]+ptable_vis
    

    new_energy = energy[j] - ptable
    
    # for positives 
    shifted_values = np.zeros((4))
    
    for i, col in enumerate(df_p.columns[2:6]):
        temp = np.interp(new_energy, df_p['Ex'].values, df_p[col].values)
        shifted_values[i] =  np.exp(ctable* np.sqrt(np.abs(new_energy)))* temp 
        
    pos_values = np.sum(shifted_values)

    # for negatives
    shifted_values = np.zeros((4))
    
    for i, col in enumerate(df_n.columns[2:6]):
        temp = np.interp(new_energy, df_n['Ex'].values, df_n[col].values)
        shifted_values[i] =  np.exp(ctable* np.sqrt(np.abs(new_energy)))* temp
        
    neg_values = np.sum(shifted_values)


    # adding both
    ld_ef = neg_values+pos_values


    return ld_ef





# Define the likelihood function for given errors sigma
def likelihood(params,arguments):
#Assumed format for data=[xvals,yvals]
    data, model, sigmas = arguments
    likelihood_log_val=0

    for i in range(len(data[0])):
        likelihood_log_val=likelihood_log_val-1/2*((data[1][i] - model(i,params)) / sigmas[i])**2\
        -np.log(2*np.pi*sigmas[i]**2)/2
      
        
    return np.exp(likelihood_log_val)


# define prior model
def prior_model_ld5(params_vals,arguments):
    params0,params0_Cov_Inv_matrix=arguments
    

    # This condition to ensure that energy is not negative when interpolating
    if params_vals[1]>1.041:
        return 0

    else:
        mu=np.array(params_vals)-np.array(params0)
        params_size=len(params_vals)
        return (2*np.pi)**(-params_size/2)*np.sqrt(np.linalg.det(params0_Cov_Inv_matrix))*np.exp(-np.dot(mu,np.dot(params0_Cov_Inv_matrix,mu))/2)



# Markov Chain Monte Carlo (MCMC) 

def metropolis(data,sigma, prior,prior_arguments, likelihood,model,\
               num_iterations, step_size):
#     step_size should be a list the size of the parameters of the model
    likelihood_arguments=[data, model, sigma]
    initial_parameters=prior_arguments[0]
    #thermalizing
    burn_samples=1000
    # Set the initial state of the chain
    params_current=initial_parameters
    params_list=[]
    posterior_list=[]
    
    acceptance_times=0
    
    cov_step_size=np.diag(step_size)**2
    
    posterior_current=(likelihood(params_current,likelihood_arguments))*(prior(params_current,\
                                                                               prior_arguments))
    
    # Run the Metropolis-Hastings algorithm for burning
    for i in range(burn_samples):
        # Propose a new state for the chain
        params_proposed=np.random.multivariate_normal(params_current,cov_step_size)
        
        posterior_proposed=(likelihood(params_proposed,likelihood_arguments))*(prior(params_proposed,\
                                                                               prior_arguments))
        
        # Calculate the acceptance probability
        acceptance_prob = min(1, posterior_proposed / posterior_current)

        # Accept or reject the proposal
        if np.random.uniform() < acceptance_prob:
            params_current = params_proposed
            posterior_current=posterior_proposed


    for i in range(num_iterations):
        params_proposed=np.random.multivariate_normal(params_current,cov_step_size)
        
        posterior_proposed=(likelihood(params_proposed,likelihood_arguments))*\
        (prior(params_proposed,prior_arguments))
        
        # Calculate the acceptance probability
        acceptance_prob = min(1, posterior_proposed / posterior_current)

        # Accept or reject the proposal
        if np.random.uniform() < acceptance_prob:
            params_current = params_proposed
            posterior_current=posterior_proposed
            acceptance_times=acceptance_times+1

        # Store the current state
        params_list.append(params_current)
        posterior_list.append(posterior_current)
        
    
    #Rule of thumb acceptance is around 50%. 
    #You could plot the accuracy of the estimations as a function of this rate, that would be interesting to see. 
    print(acceptance_times/num_iterations*100,"%")
    
    return(np.array(params_list),np.array(posterior_list),\
           acceptance_times/num_iterations*100)



prior_arguments_A=[[0,0],np.linalg.inv(np.diag([5**2,5**2]))]

alpha_rand2 = np.loadtxt('output_data/gsf_post.txt')

print(len(alpha_rand2))
#alpha_rans2=alpha_rand2[:2]

select_sub =[]

# loop for different value values of slope

for i in range(len(alpha_rand2)):
    print("start",i)
    print(alpha_rand2[i,0])
    ld_c = ld * np.exp(-alpha_rand2[i,4]* energy)
    error_c = error*  np.exp(-alpha_rand2[i,4]* energy)

    results_A=metropolis([energy,ld_c],error_c, prior_model_ld5,\
                         prior_arguments_A, likelihood,model_ld_100,100000, [0.1,0.1])

    all_chains =results_A[0]

    rng = np.random.default_rng()
    alpha_rand_ld = rng.choice(all_chains,(100),replace=False)

    print("end",i)

    select_sub.append(alpha_rand_ld)


combined = np.vstack(select_sub)

np.save("output_data/nld_post.txt", combined)

