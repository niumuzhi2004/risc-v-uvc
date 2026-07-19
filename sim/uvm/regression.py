import re
import subprocess

"""
Tests to run and the number of iterations.
For constrained random tests, each iteration has a different seed. 
Directed tests are only run once with a fixed seed.
"""

test_plan = {
    "constrained_random_test":  {"abbr": "rand",         "count": 100},
    "rand_without_jump_test":   {"abbr": "rand_no_jump", "count": 50},
    "addr_alignment_test":      {"abbr": "addr_align",   "count": 1},
    "consecutive_hazards_test": {"abbr": "hazard",       "count": 1},
    "invalid_branch_test":      {"abbr": "inval_branch", "count": 1},
    "invalid_jal_test":         {"abbr": "inval_jal",    "count": 1},
    "invalid_jalr_test":        {"abbr": "inval_jalr",   "count": 1},
    "directed_testing_test":    {"abbr": "directed",     "count": 1}
}


# analyze files and elaborate design
print("Analyzing files and elaborating design...")
subprocess.run(
    ["vivado", "-mode", "batch", "-source", "./uvm/build.tcl"],
    shell=True
)


# run tests
cov_db_list = []

def run_test(test_name, seed, cov_name):
    result = subprocess.run([
        "vivado", "-mode", "batch", "-source", "./uvm/run.tcl",
        "-tclargs", test_name, str(seed), cov_name
    ], shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"WARNING: Return code {result.returncode} running test {test_name} with seed {seed}.")

for test_name, test_specs in test_plan.items():
    for i in range(test_specs["count"]):
        print(f"Running test {test_name} with seed {i}...")
        cov_name = "".join([test_specs["abbr"], '_', str(i)])
        cov_db_list.append(cov_name)
        run_test(test_name, i, cov_name)


# parse log for test pass/fail status
print("Parsing log files for test results...")

pass_count = 0
fail_count = 0
error_count = 0
fatal_count = 0
warning_count = 0
assertion_failure_count = 0

for test_name, test_specs in test_plan.items():
    for i in range(test_specs["count"]):
        with open(f"./{test_name}_{i}.log", 'r') as file:
            for line in file:

                match = re.search(r'(\d+) instructions passed, (\d+) failed', line)
                if match:
                    pass_count += int(match.group(1))
                    fail_count += int(match.group(2))
                    if int(match.group(2)) > 0:
                        print(f"Failed Test: {test_name} Seed: {i}: \n {line}")
                
                elif "UVM_ERROR @" in line:
                    error_count += 1
                    print(f"Error in test: {test_name} SEED: {i}: \n {line}")
                
                elif "UVM_FATAL @" in line:
                    fatal_count += 1
                    print(f"Fatal error in test: {test_name} SEED: {i}: \n {line}")
                
                elif "UVM_WARNING @" in line and "WATCHDOG" not in line:
                    warning_count += 1
                    print(f"Warning in test: {test_name} SEED: {i}: \n {line}")
                
                elif "Error: SVA Violation" in line:
                    assertion_failure_count += 1
                    print(f"Assertion failure in test: {test_name} SEED: {i}: \n {line}")



# print summary
print("---------------SUMMARY---------------")
print("Total Tests Run: ", pass_count + fail_count)
print("Total Tests Passed: ", pass_count)
print("Total Tests Failed: ", fail_count)
print("Total Errors: ", error_count)
print("Total Fatals: ", fatal_count)
print("Total Warnings: ", warning_count)
print("Total Assertion Failures: ", assertion_failure_count)


# merge coverage data and generate report
subprocess.run(
    ["vivado", "-mode", "batch", "-source", "./uvm/generate_cov_report.tcl", "-tclargs"]
    + cov_db_list, shell=True, capture_output=True, text=True
)