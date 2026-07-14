# accept external arguments for regression
if {$argc == 3} {
    set test [lindex $argv 0]
    set seed [lindex $argv 1]
    set cov  [lindex $argv 2]
} else {
    set test "constrained_random_test"
    set seed 1
    set cov  "default"
}

# run simulation
exec xsim tb_top_snapshot \
    -testplusarg UVM_TESTNAME=$test \
    -sv_seed $seed \
    -cov_db_name $cov \
    -cov_db_dir ./cov_db \
    -runall \
    -gui -tclbatch ./smoke/wave.tcl \
    -log ${test}_${seed}.log

exit