This is the starting point before we hit Bayesian . Here we create base models so that Bayesian can use it in later steps

# Step 1
->First we start with GSF. Three parameters we interested in this notebook are the ubpende , upbendc , ftable of GSF in TALYS models. So we set all of them to (0,0,1) , run TALYS (input_gsf.txt) and the resulting GSF which we get in the output.dat files is saved as base_strength.txt or master_base_gsf.pkl.

-> Once we have this we can check whether changing parameters using master_base_gsf.pkl is same as changing parameters in TALYS using the notebook check_gsf.ipynb

 For this open the check_gsf.ipynb. Choose some random values if upbende, upbendc and ftable and save it as optimal_talys.txt. Then in the construct section , you need to input the same upbende , upbendc and ftable values. If everything goes values construct and talys should look the same.



# Step 2
-> We move onto nld. Since we use ldmodel 5 and we will use interpolations in the actual Bayesian. We need to get many ptable values and concatenate . So in TALYS run the script ld_txt_files/repeat_all.sh with ld_txt_files/input.txt. This creates a set of output files labeled
output_{ptable_value}_parity.txt in the folder ld_txt_files. ( An example txt file is shown as output_0.05_p.txt).

-> Then we need to concatenate all these textfiles to create a master database called master_base_ld_n.pkl and master_base_ld_p.pkl. (These file are used in the actual Bayesian Step). This is achieved using the notebook titled copied_concat.ipynb

-> Just like for GSF , we can check changing parameter using masterdatabase is same as same as changing paramterer in talys using the notebook check_ld.ipynb.

 For this open the check_ld.ipynb. Choose some random values if ctable and ptable and save it as testing_p.txt and testing_n.txt. Then in the construct section , you need to input the same ctable and ptable values. If everything goes values construct and talys should look the same.


 The base_ld_n.pkl and base_ld_p.pkl is made by just ptable=0 and ctable =0.